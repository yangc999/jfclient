--region *.lua
--Date
--请求抽奖的转盘列表
local LotteryProxy = import("..proxy.LotteryProxy")
local LotteryMediator = import("..mediator.LotteryMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestLotteryListCommand = class("RequestLotteryListCommand", SimpleCommand)

--显示loading进度条
function RequestLotteryListCommand:showLoading(notification)
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    --重新请求奖品列表
    local function retryReq()
         local strMsg = "抽奖列表请求失败,是否重试?"
         local function okCall()  --确定按钮回调
            self:execute(notification)
         end
         local tMsg = {mType = 2, msg = strMsg, okCallback = okCall} --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
         platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX_EX, tMsg)  --弹出MsgBox，等用户确定。真正的购买请求在MSGBOX_OK消息处理里
    end
    --显示转圈条
    cc.exports.showLoadingAnim("正在请求抽奖列表...","抽奖列表请求失败", retryReq, 5)
end

--重新请求商品列表
function RequestLotteryListCommand:retryReqShopList(notification)
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local strMsg = "抽奖列表请求失败,是否重试?"
    local function okCall()  --确定按钮回调
       self:execute(notification)
    end 
    local tMsg = {mType = 2, msg = strMsg, okCallback = okCall} --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
    platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX_EX, tMsg)  --弹出MsgBox，等用户确定。真正的购买请求在MSGBOX_OK消息处理里
end

function RequestLotteryListCommand:execute(notification)
    print("RequestLotteryListCommand")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
	local lotteryProxy = platformFacade:retrieveProxy("LotteryProxy")

    local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING --/activities
	xhr:open("POST", load:getData().serviceUrl.."activities")   --请求抽奖的服务地址 local testUrl = "http://192.168.0.242:18890/" 在LoadProxy.lua文件中设定

     --显示loading
     self:showLoading(notification)

    --请求抽奖奖品列表服务器返回的回调函数
    local function onReadyStateChange()
        if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
            local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "activities::ActivityMsg")
			local _, res3 = tarslib.decode(res2.vecData, "activities::RspRollerListData")
			local freelist = {}   --免费抽奖列表
            local viplist = {}     --vip抽奖列表
            --dump(res1,"res1:")
            --dump(res2,"res2结果")
            dump(res3, "res3抽奖列表结果:")
            
            if res3.iResult==0 then --返回结果成功
                --隐藏loading界面
                cc.exports.hideLoadingAnim()

                --填充免费抽奖奖品列表        
                for _,v in ipairs(res3.vFreeRollerData) do
				    table.insert(freelist, v)
			    end
                --填充幸运抽奖奖品列表
                for _,v in ipairs(res3.vPayRollerData) do
				    table.insert(viplist, v)
			    end
                
                --设置抽奖列表
                lotteryProxy:getData().freeGiftList = freelist --免费抽奖列表
                lotteryProxy:getData().vipGiftList = viplist    --付费抽奖列表
                lotteryProxy:getData().freeTimes = res3.iFreeTimes  --免费抽奖次数
                lotteryProxy:getData().payTimes = res3.iPayTimes    --付费抽奖次数
                --dump(lotteryProxy:getData().freeGiftList,"免费列表")
                --dump(lotteryProxy:getData().vipGiftList,"vip列表")
                platformFacade:sendNotification(PlatformConstants.UPDATE_LOTTERYLIST)  --发送更新显示抽奖列表的信息
            else
               print("获取抽奖列表失败! 结果码：" .. res3.iResult)
               self:retryReqShopList(notification)
            end
        else
            print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
            platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
            --self:retryReqShopList(notification)
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onReadyStateChange)

    --发送请求抽奖列表请求
    local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		  iUid = login:getData().uid   --请求的用户ID
	}
	local req1 = tarslib.encode(pak1, "activities::ReqRollerListData")
    local pak2 = {
		  eAct = 1,    --LUCK_ROLLER_LIST = 1,     //请求幸运转盘列表     在ActivitysHttpProto.tars文件里
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
      print("xhr:send 抽奖的奖品列表请求")
end

return RequestLotteryListCommand
--endregion
