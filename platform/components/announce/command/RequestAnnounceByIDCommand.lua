--region *.lua
--Date 2017/11/7
--yangyisong

local AnnounceProxy = import("..proxy.AnnounceProxy")
local AnnounceListMediator = import("..mediator.AnnounceListMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestAnnounceByIDCommand = class("RequestAnnounceByIDCommand", SimpleCommand)

function RequestAnnounceByIDCommand:execute(notification)
	local announceId = notification:getBody()  --获取请求的公告ID
	print("RequestAnnounceByIDCommand:execute id:" .. announceId)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
	local login = platformFacade:retrieveProxy("LoginProxy")
	local announceProxy = platformFacade:retrieveProxy("AnnounceProxy")
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."config")   --设定请求地址 local testUrl = "http://192.168.0.242:18890/" 在LoadProxy.lua文件中
	--请求公告内容服务器返回的回调函数
	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			  --print("start onReadyStateChange")
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			  --print("res1:"..res1.vecData)
			local _, res2 = tarslib.decode(res1.vecData, "commonstruct::CommonRespHead")
			  --print("res2:"..res2.respBodyBytes)
			local _, res3 = tarslib.decode(res2.respBodyBytes, "systemconfig::GetAnnouncementByIdResp")
			  --dump(res2,"res2结果码:")
			if res2.resultCode==0 then --成功返回公告内容
				local annContent = res3  --获取正文
				--print("公告内容:" .. annContent)
				dump(res3, "公告 res3.body")
				platformFacade:sendNotification(PlatformConstants.SHOW_ANNOUNCECONTENT, annContent)  --发通知更新显示公告信息
				--将公告内容加入到公告详细列表里
				local anDetail = {id=announceId, content=annContent}
				local bFound = false
				--检查是否有重复的公告ID,有的话就替换新的公告内容
				for _,v in ipairs(announceProxy:getData().anConlist) do
					if v.id==announceId then
						v.content = annContent
						bFound = true
						break
					end
				end
				if bFound==false then
					table.insert(announceProxy:getData().anConlist, anDetail)
				end
				local anDelList = announceProxy:getData().anConlist
				dump(anDelList, "announceProxy:getData().anConlist")
			else
				local errInfo = "返回公告内容失败，结果码：" .. res2.resultCode
				platformFacade:sendNotification(PlatformConstants.SHOW_ANNOUNCECONTENT, errInfo)
			end
		  
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChange)

	--发送公告列表请求
	local tarslib = cc.load("jfutils").Tars
  local pak1 = {
	id = announceId   --请求的公告ID
  }
	local req1 = tarslib.encode(pak1, "systemconfig::GetAnnouncementByIdReq")  --systemconfig::ListAnnouncementBaseReq
	local pak2 = {
	actionName = 7,    --commonstruct::ActionName中有个枚举值CONF_LIST_ANNOUNCEMENT_BASE=6,     在CommonStruct.tars文件里
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
  xhr:send(req3)  --发送公告请求
end

return RequestAnnounceByIDCommand
--endregion
