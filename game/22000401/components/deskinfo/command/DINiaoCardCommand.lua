
local SimpleCommand = cc.load("puremvc").SimpleCommand
local DINiaoCardCommand = class("DINiaoCardCommand", SimpleCommand)

function DINiaoCardCommand:execute(notification)
    print("-------------->DINiaoCardCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("DeskInfoProxy"):getData()

    if name == MyGameConstants.NIAO_CARD then
        data.NiaoCardData = body.vNiaoTiles
        data.NiaoCard = body.vNiaoTiles
    end
end

return DINiaoCardCommand