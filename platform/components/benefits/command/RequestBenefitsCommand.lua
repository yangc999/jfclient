--首次进入大厅请求所有福利信息
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestBenefitsCommand = class("RequestBenefitsCommand", SimpleCommand)

function RequestBenefitsCommand:execute(notification)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
	local benefits = platformFacade:retrieveProxy("BenefitsProxy")

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."task")
	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
            dump(res1)
            local _, res2 = tarslib.decode(res1.vecData, "task::TTaskServiceMsg")
            dump(res2)
			local _, res3 = tarslib.decode(res2.vecData, "task::TRspTask")
            dump(res3)

            for k, v in pairs (res3.vTaskList) do
                if v.vTaskrelative ~= nil then
                    dump(v.vTaskrelative)
                end
            end
            

            if res3.iRetCode == 0 then
                benefits:getData().taskInfo = res3.vTaskList         
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
        lUid = login:getData().uid,               --玩家ID
		vTaskidList = benefits:getData().taskID,        --指定任务ID
		sTriggerKey = 0       --触发参数
	}
	local req1 = tarslib.encode(pak1, "task::TReqTask")
	local pak2 = {
		eAct = 0, 
		vecData = req1, 
	}
	local req2 = tarslib.encode(pak2, "task::TTaskServiceMsg")
	local pak3 = {
		iVer = load:getData().version, 
		iSeq = load:getData().sequence, 
		stUid = {
			lUid = login:getData().uid, 
			sToken = login:getData().token, 
		}, 
		vecData = req2, 
	}
    dump(pak3)
	local req3 = tarslib.encode(pak3, "JFGame::THttpPackage")
	xhr:send(req3)
end



return RequestBenefitsCommand