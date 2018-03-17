local SimpleCommand = cc.load("puremvc").SimpleCommand
local OCCurSameCardCommand = class("OCCurSameCardCommand", SimpleCommand)

function OCCurSameCardCommand:execute(notification)
    print("-------------->OCCurSameCardCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("OutCardProxy"):getData()

    if name == MyGameConstants.C_SHOW_CURSAME_CARD then
        data.ClickCardValue = body.value
    end
end

return OCCurSameCardCommand