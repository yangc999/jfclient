--region *.lua
--Date
--用户请求抽奖的命令
local LotteryProxy = import("..proxy.LotteryProxy")
local LotteryMediator = import("..mediator.LotteryMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestDrawLotteryCommand = class("RequestDrawLotteryCommand", SimpleCommand)

--显示loading进度条
function RequestDrawLotteryCommand:showLoading()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    --关闭抽奖界面，返回大厅
    local function backHall()
        platformFacade:removeMediator("LotteryMediator")
    end
    --显示转圈条
    cc.exports.showLoadingAnim("正在请求游戏列表...","您的网络不稳定，请稍后再试", backHall, 5)
end

function RequestDrawLotteryCommand:execute(notification)
    print("RequestDrawLotteryCommand")
    local rollerType = notification:getBody()  --获取请求的抽奖类型
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
	local lotteryProxy = platformFacade:retrieveProxy("LotteryProxy")

    local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING --/activities
	xhr:open("POST", load:getData().serviceUrl.."activities")   --请求抽奖的服务地址 local testUrl = "http://192.168.0.242:18890/" 在LoadProxy.lua文件中设定

    --显示loadingUI
    self:showLoading()

    --请求抽奖奖品结果服务器返回的回调函数
    local function onReadyStateChange()
        if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
            print("抽奖结果返回")
            local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "activities::ActivityMsg")
			local _, res3 = tarslib.decode(res2.vecData, "activities::RspLotteryDraw")
			local drawResult = nil  --抽奖结果
            --dump(res2,"res2抽奖结果:")
            dump(res3, "res3抽奖结果:")
            if res3 == nil then
               print("服务器未返回数据 res3 = nil")
               platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "服务器未返回数据")
               platformFacade:sendNotification(PlatformConstants.RESULT_ROLLER, false) --发送抽奖失败的信息
               return
            end
            if res3.iResult==0 then --返回结果成功
                --填充免费抽奖奖品列表
                lotteryProxy:getData().rollerResult = res3.rAwardInfo
                lotteryProxy:getData().freeTimes = res3.iFreeTimes  --剩余免费抽奖次数
                lotteryProxy:getData().payTimes = res3.iPayTimes   --剩余付费抽奖次数
                platformFacade:sendNotification(PlatformConstants.RESULT_ROLLER, true)  --发送更新显示抽奖列表的信息
            else
               print("获取抽奖结果失败! 结果码：" .. res3.iResult)
               platformFacade:sendNotification(PlatformConstants.RESULT_ROLLER, false) --发送抽奖失败的信息
            end
        else
            print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
            platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
            cc.exports.hideLoadingAnim()
        end --end if
        xhr:unregisterScriptHandler()
    end --end function onReadyStateChange
    xhr:registerScriptHandler(onReadyStateChange)

    --发送请求抽奖请求
    local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		  iUid = login:getData().uid,   --请求的用户ID
          iRollerType = rollerType,      --请求抽奖的类型 1.免费抽奖 2.付费抽奖
	}
	local req1 = tarslib.encode(pak1, "activities::ReqLotteryDraw")
    local pak2 = {
		  eAct = 2,    --LUCK_ROLLER_CLICK = 2,     //请求幸运转盘列表     在ActivitysHttpProto.tars文件里
		  vecData = req1, 
	}
	local req2 = tarslib.encode(pak2, "activities::ActivityMsg")
    --下面是拼Http头，写法都是固定
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
    print("xhr:send 抽奖请求")
end

return RequestDrawLotteryCommand
--endregion
