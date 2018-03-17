--region *.lua
--Date 2017/11/3
--请求公告列表

local AnnounceProxy = import("..proxy.AnnounceProxy")
local AnnounceListMediator = import("..mediator.AnnounceListMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestAnnounceListCommand = class("RequestAnnounceListCommand", SimpleCommand)

function RequestAnnounceListCommand:execute(notification)
    --local announceId = notification:getBody()  --获取请求的ID
    print("RequestAnnounceListCommand:execute")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    --platformFacade:registerProxy(AnnounceProxy.new())
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
	local announceProxy = platformFacade:retrieveProxy("AnnounceProxy")

    local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."config")   --设定请求地址 local testUrl = "http://192.168.0.242:18890/" 在LoadProxy.lua文件中
    --请求公告列表服务器返回的回调函数
    local function onReadyStateChange()
        if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
            local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "commonstruct::CommonRespHead")
			local _, res3 = tarslib.decode(res2.respBodyBytes, "systemconfig::ListAnnouncementBaseResp")
			local anlist = {}   --公告列表
            --dump(res2,"res2结果码:")
            if res2.resultCode==0 then
              --填充公告列表
              for _,v in ipairs(res3.announcementBaseList) do
				 table.insert(anlist, v)
			  end
            else
               print("获取公告列表失败!")
            end

            --dump(anlist,"公告列表")
            --设置公告代理的公告列表
            announceProxy:getData().anlist = anlist
            platformFacade:sendNotification(PlatformConstants.SHOW_ANNOUNCELIST)  --更新显示公告信息
        else
        	print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
        	platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onReadyStateChange)
    --发送公告列表请求
    local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		id = 0   --这个id实际上没用，0没有确切意义
	}
	local req1 = tarslib.encode(pak1, "systemconfig::ListAnnouncementBaseReq")
    local pak2 = {
		actionName = 6,    --commonstruct::ActionName中有个枚举值CONF_LIST_ANNOUNCEMENT_BASE=6,     在CommonStruct.tars文件里
		reqBodyBytes = req1, 
	}
    --下面是拼Http头，写法都是固定
	local req2 = tarslib.encode(pak2, "commonstruct::CommonReqHead")
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
end

return RequestAnnounceListCommand


--endregion
