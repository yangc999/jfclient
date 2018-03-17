
local SimpleCommand = cc.load("puremvc").SimpleCommand
local CPPengReqCommand = class("CPPengReqCommand", SimpleCommand)

function CPPengReqCommand:execute(notification)
    print("-------------->CPPengReqCommand:execute")
    local name = notification:getName()
    local body = notification:getBody()
    local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants

    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("CPGMenuProxy"):getData()
    local ActNotifyData = data.ActNotifyData
    local mj_vActs = ActNotifyData.mj_vActs
    local index = 0

    for k,act in pairs(mj_vActs) do
        if act.eAction == 32 then
           index = k
           break
        end
    end

    if name == MyGameConstants.C_PENG_REQ then
        local pak1 = {
            eChosenAction =
            {
                eAction = mj_vActs[index].eAction,
                eActTile = mj_vActs[index].eActTile,
                iActCID = mj_vActs[index].iActCID,
            }
        }
        GameUtils:getInstance():sendNotification(25, pak1, "MJProto::TMJ_actionChoseCPGHG")
    end
end

return CPPengReqCommand