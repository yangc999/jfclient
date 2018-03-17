local GameLogic = import("....GameLogic")
local SimpleCommand = cc.load("puremvc").SimpleCommand
local HCGetTokenCommand = class("HCGetTokenCommand", SimpleCommand)

function HCGetTokenCommand:execute(notification)
    print("-------------->HCGetTokenCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()

    if name == MyGameConstants.GET_TOKEN then
        local deskInfo = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
        if body.iCID == GameUtils:getInstance():getSelfServerChair() then
            data.IsCanOutCard = true
            if body.eDrawedTile ~= 254 then
                table.insert(data.SelfHandCards, body.eDrawedTile)
                GameLogic:sort(data.SelfHandCards, deskInfo.LaiZi)
                if data.VisibleCards[body.eDrawedTile] ~= nil then
                    data.VisibleCards[body.eDrawedTile] = data.VisibleCards[body.eDrawedTile] + 1
                end
            end
        else
            if body.eDrawedTile ~= 254 then
                table.insert(data.AllHandCards[body.iCID + 1], body.eDrawedTile)
                GameLogic:sort(data.AllHandCards[body.iCID + 1], deskInfo.LaiZi)
            end
        end

        data.TokenData = body
    end
end

return HCGetTokenCommand