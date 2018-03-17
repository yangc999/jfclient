--region *.lua
--Date
--请求玩家的战绩列表总行数
local MatchRecordsProxy = import("..proxy.MatchRecordsProxy")
local MatchRecordsMediator = import("..mediator.MatchRecordsMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestRecordsNumCommand = class("RequestRecordsNumCommand", SimpleCommand)

function RequestRecordsNumCommand:execute(notification)
    print("RequestRecordsNumCommand:execute")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
  	local PlatformConstants = cc.exports.PlatformConstants

  	local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
  	local matchRecordProxy = platformFacade:retrieveProxy("MatchRecordsProxy")

    local xhr = cc.XMLHttpRequest:new()
  	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING --/activities
  	xhr:open("POST", load:getData().serviceUrl.."standings")
    --请求战绩数量的服务器返回的回调函数
    local function onReadyStateChange()
        if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
            local tarslib = cc.load("jfutils").Tars
      			local str = xhr.response
      			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
      			local _, res2 = tarslib.decode(res1.vecData, "standings::TStandingsMsg")
      			local _, res3 = tarslib.decode(res2.vecData, "standings::TRspRowCount")
            --dump(res1,"res1:")
            --dump(res2,"res2结果")
            dump(res3, "res3全部战绩数量结果:")
            if res3 == nil then
               print("服务器未返回数据 res3 = nil")
               --platformFacade:registerMediator(MsgBoxMediator.new(1,"服务器未返回数据"))
               platformFacade:sendNotification(PlatformConstants.UPDATE_MATCHRECORDNUM, false)
               return
            end
            if res3.iRetCode==0 then --返回结果成功
               print("战绩总行数返回成功，总行数:" .. res3.iRowCount)
               matchRecordProxy:getData().nRecordNum = res3.iRowCount
               platformFacade:sendNotification(PlatformConstants.UPDATE_MATCHRECORDNUM, true)  --发送更新显示抽奖列表的信息
            else
               print("战绩总行数返回失败! 结果码：" .. res3.iResult)
               platformFacade:sendNotification(PlatformConstants.UPDATE_MATCHRECORDNUM, false)  
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
		  lUid = login:getData().uid,   --请求的用户ID
          iGameID = 0,
	}
	local req1 = tarslib.encode(pak1, "standings::TReqRowCount")
    local pak2 = {
		  eAct = 0,    --LUCK_ROLLER_LOG_TOTAL=4, //抽奖总记录    在ActivitysHttpProto.tars文件里
		  vecData = req1, 
	}
    --下面是拼Http头，写法都是固定
	local req2 = tarslib.encode(pak2, "standings::TStandingsMsg")
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
     print("xhr:send 请求战绩总数")
end

return RequestRecordsNumCommand
--endregion
