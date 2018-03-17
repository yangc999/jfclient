
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestBenefitsConfigCommand = class("RequestBenefitsConfigCommand", SimpleCommand)

function RequestBenefitsConfigCommand:execute(notification)
    print("11111111111112222222222222222222222222")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
	local benefits = platformFacade:retrieveProxy("BenefitsProxy")

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."config")
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
            print("textTaskId = "..textTaskId)
            --·¢ËÍÊý¾ÝÇëÇó

            local taskIDTempData = self:stringSplit(textTaskId, ",")
            for i = 1,#taskIDTempData do
                taskIDTempData[i] = tonumber(taskIDTempData[i])
            end
            dump(taskIDTempData)
            
            benefits:getData().taskID = taskIDTempData
            dump(benefits:getData().taskID)

            --获取每日赚金任务数据
	        print("get taskInfo")
	        print("125222222")
	        platformFacade:sendNotification(PlatformConstants.REQUEST_BENEFITS)

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
		confKey = "benefits_task_ids", 
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

--function RequestBenefitsConfigCommand.stringSplit(input, delimiter)
--    input = tostring(input)
--    delimiter = tostring(delimiter)
--    if (delimiter=='') then return false end
--    local pos,arr = 0, {}
--    for st,sp in function() return string.find(input, delimiter, pos, true) end do
--        table.insert(arr, string.sub(input, pos, st - 1))
--        pos = sp + 1
--    end
--    table.insert(arr, string.sub(input, pos))
--    return arr
--end

function RequestBenefitsConfigCommand:stringSplit( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

return RequestBenefitsConfigCommand