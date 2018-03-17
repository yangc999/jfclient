--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local RealNameProxy = import("..proxy.RealNameProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestRealNameCommand = class("RequestRealNameCommand", SimpleCommand)

function RequestRealNameCommand:execute(notification)
    print("RequestRealNameCommand:execute")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
	local realNameProxy = platformFacade:retrieveProxy("RealNameProxy")

    local reqRealName = notification:getBody()
    dump(reqRealName, "reqRealName")
    local name = reqRealName.realName  --用户名
    local cardNum = reqRealName.idNum --身份证号

    local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."userinfo")   --设定请求地址 local testUrl = "http://192.168.0.242:18890/" 在LoadProxy.lua文件中

    --请求实名认证的回调函数
    local function onReadyStateChange()
       print("RequestRealNameCommand onReadyStateChange")
       if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
          local tarslib = cc.load("jfutils").Tars
		  local str = xhr.response
          print("str:" .. str)
          local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
          dump(res1,"res1")
		  local _, res2 = tarslib.decode(res1.vecData, "userinfo::TUserInfoMsg")
          dump(res2,"res2")
		  local _, res3 = tarslib.decode(res2.vecData, "userinfo::TRspRealName")
          if res3.iRetCode == 0 then --请求实名认证成功
             print("实名认证成功")
             platformFacade:sendNotification(PlatformConstants.RESULT_REALNAME, true)
             realNameProxy:getData().name = name
             realNameProxy:getData().id = cardNum
          else
             print("实名认证失败,结果码:" .. res3.iRetCode)
             platformFacade:sendNotification(PlatformConstants.RESULT_REALNAME, false)
             if res3.iRetCode == 305 then
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "您的身份证号码无效")
             elseif res3.iRetCode == 306 then
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "您已经认证过啦")
             else
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "实名认证失败")
                realNameProxy:getData().name = ""
                realNameProxy:getData().id = ""
             end
             
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
		lUid = login:getData().uid,
        sRealname = name,
        sIdcNo = cardNum,
	}
	local req1 = tarslib.encode(pak1, "userinfo::TReqRealName")  --请求手机验证码
    local pak2 = {
		eAct = 5,   --E_A_REALNAME=5,			//实名认证
		vecData = req1, 
	}
    dump(pak2,"pak2")
	local req2 = tarslib.encode(pak2, "userinfo::TUserInfoMsg")
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
    print("send msg")
	xhr:send(req3)
    print("end xhr:send")
end

return RequestRealNameCommand
--endregion
