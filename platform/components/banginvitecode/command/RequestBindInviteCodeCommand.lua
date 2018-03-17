--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestBindInviteCodeCommand = class("RequestBindInviteCodeCommand", SimpleCommand)
function RequestBindInviteCodeCommand:ctor()
    print("-------------->RequestBindInviteCodeCommand:ctor")
    RequestBindInviteCodeCommand.super.ctor(self)
end

function RequestBindInviteCodeCommand:execute(notification)
    local tReqBody = notification:getBody()
    local reqTaskID = tReqBody.taskID  --任务ID
    local inviteCode = tReqBody.inviteCode   --邀请码
    print("RequestBindInviteCodeCommand:execute taskID:" .. reqTaskID .. " inviteCode:"..inviteCode)
    

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
            dump(res1)
            local _, res2 = tarslib.decode(res1.vecData, "task::TTaskServiceMsg")
            dump(res2)
			local _, res3 = tarslib.decode(res2.vecData, "task::TRspPerformTask")
            dump(res3)

            local taskInfo = clone(taskProxy:getData().taskInfo)
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

                        break
                    end  
                end
                dump(taskInfo)
                taskProxy:getData().taskInfo = taskInfo
                platformFacade:removeMediator("BindFriendInviteCodeMediator")
                print("send SHARE_FINISH tReqBody:",reqTaskID)
                platformFacade:sendNotification(PlatformConstants.SHARE_FINISH,reqTaskID)  --绑定成功消息
                -- platformFacade:sendNotification(PlatformConstants.UPDATE_TASKSHARE_INFO)  --发消息更新任务列表
                -- platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "绑定邀请码成功")
                -- platformFacade:removeMediator("BindFriendInviteCodeMediator") --关闭绑定邀请码UI
                -- platformFacade:sendNotification(PlatformConstants.REQUEST_TASKSHARE_AWARD, 9)  --请求完成发邀请码成功任务消息

            elseif res3.iRetCode == 1107 then 
                platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "未达到领取条件")
            elseif res3.iRetCode == 1103 then 
                platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "请勿重复领取奖励")
            elseif res3.iRetCode == 1104 then 
                platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "不可重复领取任务及奖励")
            elseif res3.iRetCode == 1105 then 
                platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "今日任务次数已完成")
            elseif res3.iRetCode == 1106 then 
                platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "获取奖励信息失败")
            elseif res3.iRetCode == 1107 then 
                platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "领取奖励不符合要求")
            elseif res3.iRetCode == 1109 then 
                platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "邀请码不存在")
            elseif res3.iRetCode == 1120 then 
                platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "请勿以不当手段恶意刷取奖励")
            elseif res3.iRetCode == 1121 then 
                platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "任务不存在")
            else
                platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "绑定邀请码失败")
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
		iTaskId = reqTaskID,        --指定任务ID
        sTValue = inviteCode,      --邀请码
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

return RequestBindInviteCodeCommand


--endregion
