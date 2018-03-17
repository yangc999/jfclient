
local SimpleCommand = cc.load("puremvc").SimpleCommand
local AutoReqCommand = class("HostingReqCommand", SimpleCommand)

function AutoReqCommand:execute(notification)
    print("-------------->AutoReqCommand:execute")
    local name = notification:getName()
    local body = notification:getBody()
    local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")

    if name == MyGameConstants.C_AUTO then
        local pak1 = {
            iCID = GameUtils:getInstance():getSelfServerChair(),
            bAuto = body.bAuto,
        }
        GameUtils:getInstance():sendNotification(31, pak1, "MJProto::TMJ_actionPlayerAuto")
    end
end

return AutoReqCommand