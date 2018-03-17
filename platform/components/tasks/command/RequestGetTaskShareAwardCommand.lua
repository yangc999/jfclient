--region *.lua
--Date
--执行某项任务 要传入任务ID

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestGetTaskShareAwardCommand = class("RequestGetTaskShareAwardCommand", SimpleCommand)

function RequestGetTaskShareAwardCommand:ctor()
    print("-------------->RequestGetTaskShareAwardCommand:ctor")
    RequestGetTaskShareAwardCommand.super.ctor(self)
end

function RequestGetTaskShareAwardCommand:execute(notification)
    self.reqTaskID = notification:getBody()
    print("RequestGetTaskShareAwardCommand:execute taskID:" .. self.reqTaskID)
    

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
	local taskProxy = platformFacade:retrieveProxy("TaskProxy")

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."task")

	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
            dump(res1,"jayReward res1")
            local _, res2 = tarslib.decode(res1.vecData, "task::TTaskServiceMsg")
            dump(res2,"jayReward res2")
			local _, res3 = tarslib.decode(res2.vecData, "task::TRspGetTaskRewards")
            dump(res3,"jayReward res3")

            local taskInfo = clone(taskProxy:getData().taskInfo)
            if res3.iRetCode == 0 then
                
                local newTaskObj = res3.TaskInfo
                for i = 1, #taskInfo do
                    local t = clone(taskInfo[i])
                    if t.iTaskId == newTaskObj.iTaskId then
                        dump(newTaskObj,"当前任务 taskObj")
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

                        --如果是破产补助，要修改破产补助数据
                        --[[
                        if newTaskObj.iTaskId == 2 then
                            benefits:getData().assistanceGold = newTaskObj.iRewardValue
                            benefits:getData().assistanceCurrentTimes = newTaskObj.iCurrentCount
                            benefits:getData().assistanceTimes = newTaskObj.iTaskAvailableCount - newTaskObj.iCurrentCount
                        end
                        --]]
                        break
                    end  
                end
                -- dump(taskInfo,"获得任务奖励，更新任务")
                taskProxy:getData().taskInfo = taskInfo
                print("RequestGetTaskShareAwardCommand:execute send SHARE_FINISH taskID:",self.reqTaskID)
                platformFacade:sendNotification(PlatformConstants.SHARE_FINISH,self.reqTaskID)  --发分享完成消息
                platformFacade:sendNotification(PlatformConstants.UPDATE_TASKSHARE_INFO)  --发消息更新任务列表


            elseif res3.iRetCode == 1107 then 
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "未达到领取条件")
            elseif res3.iRetCode == 1103 then 
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "请勿重复领取奖励")
            elseif res3.iRetCode == 1104 then 
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "不可重复领取任务及奖励")
            else
                -- platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, res3.iRetCode)
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
		iTaskId = self.reqTaskID,        --指定执行某项任务ID
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

return RequestGetTaskShareAwardCommand


--endregion
