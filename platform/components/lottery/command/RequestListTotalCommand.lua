--region *.lua
--Date
--请求整个抽奖列表
local LotteryProxy = import("..proxy.LotteryProxy")
local LotteryMediator = import("..mediator.LotteryMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestListTotalCommand = class("RequestListTotalCommand", SimpleCommand)

function RequestListTotalCommand:execute(notification)
	print("RequestListTotalCommand:execute")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
	local login = platformFacade:retrieveProxy("LoginProxy")
	local lotteryProxy = platformFacade:retrieveProxy("LotteryProxy")

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING --/activities
	xhr:open("POST", load:getData().serviceUrl.."activities")   --请求抽奖的服务地址 local testUrl = "http://192.168.0.242:18890/" 在LoadProxy.lua文件中设定
	--请求抽奖奖品列表服务器返回的回调函数
	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "activities::ActivityMsg")
			local _, res3 = tarslib.decode(res2.vecData, "activities::RspListTotal")
			local vTotalList = {}     --用户抽奖结果列表
			dump(res1,"res1:")
			dump(res2,"res2结果")
			dump(res3, "res3全部我的抽奖列表结果:")
			
			if res3.iResult==0 then --返回结果成功
				--填充免费抽奖奖品列表 
				for _,v in ipairs(res3.vTotalList) do
					table.insert(vTotalList, v)
				end
			
				--设置抽奖列表
				lotteryProxy:getData().vTotalList = vTotalList --免费抽奖列表

				platformFacade:sendNotification(PlatformConstants.UPDATE_TOTALLOTTERYLIST)  --发送更新显示抽奖列表的信息
			else
			   print("获取抽奖列表失败! 结果码：" .. res3.iResult)
			end
		else
			print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
			platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")            
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChange)

	--发送请求抽奖列表请求
	local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		  lUid = login:getData().uid   --请求的用户ID
	}
	local req1 = tarslib.encode(pak1, "activities::ReqListTotal")
	local pak2 = {
		  eAct = 4,    --LUCK_ROLLER_LOG_TOTAL=4, //抽奖总记录    在ActivitysHttpProto.tars文件里
		  vecData = req1, 
	  }
	--下面是拼Http头，写法都是固定
	  local req2 = tarslib.encode(pak2, "activities::ActivityMsg")
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
	  xhr:send(req3)  --发送请求
	  print("xhr:send 全部抽奖纪录请求")
end

return RequestListTotalCommand
--endregion
