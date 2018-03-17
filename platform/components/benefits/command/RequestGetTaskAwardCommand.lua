
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestGetTaskAwardCommand = class("RequestGetTaskAwardCommand", SimpleCommand)

--每日签到网络请求处理函数
function RequestGetTaskAwardCommand:execute(notification)
    local reqTaskID = notification:getBody()

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
			local _, res3 = tarslib.decode(res2.vecData, "task::TRspPerformTask")
            dump(res3)

            local taskInfo = clone(benefits:getData().taskInfo)
            if res3.iRetCode == 0 then
                
                local newTaskObj = res3.TaskInfo
                for i = 1, #taskInfo do
                    local t = clone(taskInfo[i])
                    if t.iTaskId == newTaskObj.iTaskId then
                        t.iCurrentCount = newTaskObj.iCurrentCount
                        t.iRelative = newTaskObj.iRelative
                        t.iRewardStatus = newTaskObj.iRewardStatus
                        t.iRewardType = newTaskObj.iRewardType
                        t.iRewardValue = newTaskObj.iRewardValue
                        t.iTaskAvailableCount = newTaskObj.iTaskAvailableCount
                        


                        if newTaskObj.vTaskrelative ~= nil then
                            t.vTaskrelative = newTaskObj.vTaskrelative 
                            dump(newTaskObj.vTaskrelative)
                        end 

                        if newTaskObj.iExcution ~= nil  then
                            t.iExcution = newTaskObj.iExcution
                        end

                        taskInfo[i] = t
                        if newTaskObj.iTaskId == 2 and taskInfo[i].sTValue ~= nil then
                            -- 获取领低保的最低金额 ,把领取低保的情况的的sTValue存下来，执行的时候不返回此值
                            t.sTValue = taskInfo[i].sTValue
                        end
                        --如果是破产补助，要修改破产补助数据
                        if newTaskObj.iTaskId == 2 and newTaskObj.vTaskrelative ~= nil then
                            benefits:getData().assistanceGold = newTaskObj.iRewardValue
                            benefits:getData().assistanceCurrentTimes = newTaskObj.iCurrentCount
                            benefits:getData().assistanceTimes = newTaskObj.vTaskrelative[1].iTriggerValue - newTaskObj.iCurrentCount
                                                    
                        end

                        break
                    end  
                end
                dump(taskInfo)
                benefits:getData().taskInfo = taskInfo
                platformFacade:sendNotification(PlatformConstants.UPDATE_USERWEALTH)  --发通知更新用户数据里面的金币
                platformFacade:sendNotification(PlatformConstants.UPDATE_TASKINFO)      --更新显示效果

            elseif res3.iRetCode == 1107 then 
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "未达到领取条件")
            elseif res3.iRetCode == 1103 then 
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "请勿重复领取奖励")
            elseif res3.iRetCode == 1104 then 
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "不可重复领取任务及奖励")
            else
                -- platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, res3.iRetCode)
            end


--            for k, v in pairs (res3.vTaskList) do
--                if v.vTaskrelative ~= nil then
--                    dump(v.vTaskrelative)
--                end
--            end
            

--            if res3.iRetCode == 0 then
--                benefits:getData().taskInfo = res3.vTaskList            
--            end
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
		iTaskId = reqTaskID,        --指定任务ID
	}
	local req1 = tarslib.encode(pak1, "task::TReqPerformTask")
	local pak2 = {
		eAct = 1, 
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



return RequestGetTaskAwardCommand