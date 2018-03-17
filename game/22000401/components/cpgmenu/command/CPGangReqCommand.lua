
local SimpleCommand = cc.load("puremvc").SimpleCommand
local CPGangReqCommand = class("CPGangReqCommand", SimpleCommand)

local GangChoiceMediator = import("..mediator.GangChoiceMediator")

function CPGangReqCommand:execute(notification)
    print("-------------->CPGangReqCommand:execute")
    local name = notification:getName()
    local body = notification:getBody()
    local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants

    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("CPGMenuProxy"):getData()
    local ActNotifyData = data.ActNotifyData
    local mj_vActs = ActNotifyData.mj_vActs
    
    local iAnGangNums = 0  -- 暗杠个数
    for k, act in pairs(mj_vActs) do
        if act.eAction == MyGameConstants.MJActFlag.AnGang then
            iAnGangNums = iAnGangNums + 1
        end
    end

    if name == MyGameConstants.C_GANG_REQ then
        if iAnGangNums <= 1 then
            local index = 0
            for k, act in pairs(mj_vActs) do
                if act.eAction >= MyGameConstants.MJActFlag.DianGang and act.eAction <= MyGameConstants.MJActFlag.BuGang then
                    index = k
                    break
                end
            end

            local pak1 = {
                eChosenAction =
                {
                    eAction = mj_vActs[index].eAction,
                    eActTile = mj_vActs[index].eActTile,
                    iActCID = mj_vActs[index].iActCID,
                }
            }
            GameUtils:getInstance():sendNotification(25, pak1, "MJProto::TMJ_actionChoseCPGHG")
        else
            -- 多种杠牌选择界面
            gameFacade:registerMediator(GangChoiceMediator.new())
        end


    end
end

return CPGangReqCommand