
local SimpleCommand = cc.load("puremvc").SimpleCommand
local CPPassReqCommand = class("CPPassReqCommand", SimpleCommand)

function CPPassReqCommand:execute(notification)
    print("-------------->CPPassReqCommand:execute")
    local name = notification:getName()
    local body = notification:getBody()
    local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")

    if name == MyGameConstants.C_PASS_REQ then
        local pak2 = {
            eChosenAction = 
            {
                eAction = 15,
                iActCID = GameUtils:getInstance():getSelfServerChair(),
            }
        }
        GameUtils:getInstance():sendNotification(25, pak2, "MJProto::TMJ_actionChoseCPGHG")
    end
end

return CPPassReqCommand