--region *.lua
--Date
--请求任务分享配置
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestTaskShareConfigCommand = class("RequestTaskShareConfigCommand", SimpleCommand)

function RequestTaskShareConfigCommand:execute(notification)
    print("RequestTaskShareConfigCommand:execute")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
	local taskproxy = platformFacade:retrieveProxy("TaskProxy")

    local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."config")

    --请求任务分享配置服务器返回的回调函数
    local function onReadyStateChange()
        print("onReadyStateChange xhr.readyState = "..xhr.readyState)

        if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
            dump(res1)
            local _, res2 = tarslib.decode(res1.vecData, "commonstruct::CommonRespHead")
			local _, res3 = tarslib.decode(res2.respBodyBytes, "systemconfig::GetValueByKeyResp")

            
            local textTaskId = res3.confValue
            print("Task textTaskId = "..textTaskId)

            local taskIDTempData = self:stringSplit(textTaskId, ",")
            for i = 1,#taskIDTempData do
                taskIDTempData[i] = tonumber(taskIDTempData[i])
            end
            dump(taskIDTempData,"taskIDTempData")
            
            taskproxy:getData().taskID = taskIDTempData
            dump(taskproxy:getData().taskID)

            --获取分享任务数据
	        platformFacade:sendNotification(PlatformConstants.REQUEST_TASKSHARE)

            --dump(benefits)
		else
			print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
			platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChange)

    local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		confKey = "activity_task_id", 
	}
	local req1 = tarslib.encode(pak1, "systemconfig::GetValueByKeyReq")
	local pak2 = {
		actionName = 0, 
		reqBodyBytes = req1, 
	}
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
    --dump(pak3)
	local req3 = tarslib.encode(pak3, "JFGame::THttpPackage")
	xhr:send(req3)
end


function RequestTaskShareConfigCommand:stringSplit( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

return RequestTaskShareConfigCommand
--endregion
