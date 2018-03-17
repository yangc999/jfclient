
local GameLogic = import("....GameLogic")
local SimpleCommand = cc.load("puremvc").SimpleCommand
local HCOutCardReqCommand = class("HCOutCardReqCommand", SimpleCommand)

function HCOutCardReqCommand:execute(notification)
    print("-------------->HCOutCardReqCommand:execute")
    local name = notification:getName()
    local body = notification:getBody()
    local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants

    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()

    if name == MyGameConstants.C_OUTCARD_REQ then
        gameFacade:sendNotification(MyGameConstants.C_CLOSE_TINGCARDS)
        data.IsCanOutCard = false
        print(" outcardvalue = " .. body.value)
        -- 删除手中的一张牌
        GameLogic:removeOneItemInTable(data.SelfHandCards, body.value)
        local deskInfo = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
        GameLogic:sort(data.SelfHandCards, deskInfo.LaiZi)
        data.OutCardValue = body.value
        gameFacade:sendNotification(MyGameConstants.C_CANCEL_CURSAME_CARD)

        -- 发送出牌请求
        local pak1 = {
            iCID = GameUtils:getInstance():getSelfServerChair(),
            eDisCardedTile = body.value
        }
        GameUtils:getInstance():sendNotification(23, pak1, "MJProto::TMJ_actionDoDiscard")
    end
end

return HCOutCardReqCommand