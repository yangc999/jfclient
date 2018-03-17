local GameLogic = import("....GameLogic")
local SimpleCommand = cc.load("puremvc").SimpleCommand
local HCOutCardCommand = class("HCOutCardCommand", SimpleCommand)

function HCOutCardCommand:execute(notification)
    print("-------------->HCOutCardCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()

    if name == MyGameConstants.OUTCARD_INFO then
        gameFacade:sendNotification(MyGameConstants.C_CLOSE_TINGCARDS)
        local deskInfo = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
         -- 删除手中的一张牌
        if body.iCID == GameUtils:getInstance():getSelfServerChair() and (#data.SelfHandCards)%3 == 2 then
            GameLogic:removeOneItemInTable(data.SelfHandCards, body.eDisCardedTile)
            GameLogic:sort(data.SelfHandCards, deskInfo.LaiZi)
        end

        if body.iCID == GameUtils:getInstance():getSelfServerChair() then
            data.IsCanOutCard = false
        else
            if GameUtils:getInstance():getGameType() == 10 and body.eDisCardedTile ~= 254 then
                GameLogic:removeOneItemInTable(data.AllHandCards[body.iCID + 1], body.eDisCardedTile)
                GameLogic:sort(data.AllHandCards[body.iCID + 1], deskInfo.LaiZi)
            end

            if data.VisibleCards[body.eDisCardedTile] ~= nil then
                data.VisibleCards[body.eDisCardedTile] = data.VisibleCards[body.eDisCardedTile] + 1
            end
        end
        
        data.OutCardData = body
    end
end

return HCOutCardCommand