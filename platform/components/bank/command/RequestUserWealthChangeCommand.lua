--region *.lua YANGYISONG
--Date 2017/11/10
-- 请求用户财富 如金币信息

local BankProxy = import("..proxy.BankProxy")
local BankMediator = import("..mediator.BankMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestUserWealthChangeCommand = class("RequestUserWealthChangeCommand", SimpleCommand)

function RequestUserWealthChangeCommand:execute(notification)
    print("RequestUserWealthCommand:execute")
    --dump(notification,"RequestUserWealthCommand notification")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
	local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
	local bankProxy = platformFacade:retrieveProxy("BankProxy")
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")  --获取用户信息，里面有财富值
    local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."userinfo")   --设定请求地址 local testUrl = "http://192.168.0.242:18890/" 在LoadProxy.lua文件中
    --请求用户的财富服务器返回的回调函数
    local function onReadyStateChange()
       if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
          local tarslib = cc.load("jfutils").Tars
		  local str = xhr.response
          print("start onReadyStateChange")
		  local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
          print("res1:"..res1.vecData)
		  local _, res2 = tarslib.decode(res1.vecData, "userinfo::TUserInfoMsg")  --请求用户财富
          print("res2:"..res2.vecData)
		  local _, res3 = tarslib.decode(res2.vecData, "userinfo::TRspUserWealth") --用户财富响应数据
          dump(res3,"res3结果码:")
           if res3.iRetCode==0 then --成功返回用户财富
              print("返回用户财富变化信息成功")
              local userWealthAfter = res3.eAfterChange  --获取变更后用户财富
              dump(userWealthAfter, "查询用户财富变化值:")
              if userWealthAfter.eWealthType == Eum_WealthType.E_WT_GOLD then --金币更新
                  bankProxy.getData().gold = userWealthAfter.lAfterValue  --更新proxy上的用户数据
                  userinfo.getData().gold = userWealthAfter.lAfterValue
              elseif userWealthAfter.eWealthType == Eum_WealthType.E_WT_SAFESGOLD then --保险箱金币变化了
                  bankProxy.getData().safeGold = userWealthAfter.lAfterValue  --更新proxy上的用户数据
                  userinfo.getData().safeGold = userWealthAfter.lAfterValue
              end
             
             -- platformFacade:sendNotification(PlatformConstants.UPDATE_USERWEALTH)  --发通知更新显示公告信息
           else
             local errInfo = "返回用户财富信息失败，结果码：" .. res3.iRetCode
             print(errInfo)
            -- platformFacade:sendNotification(PlatformConstants.UPDATE_USERWEALTH, errInfo)
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
		lUid = login:getData().uid,   --用户ID
		iModif = 1,                         --更新数据
        eWealthChange = 10, --暂时
	}
	local req1 = tarslib.encode(pak1, "userinfo::TReqUserWealth")
	local pak2 = {
		eAct = 2,   --查询财富值
		vecData = req1, 
	}
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
	xhr:send(req3)
end

return RequestUserWealthChangeCommand


--endregion
