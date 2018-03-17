
local SimpleCommand = cc.load("puremvc").SimpleCommand
local PIGameStationCommand = class("PIGameStationCommand", SimpleCommand)

function PIGameStationCommand:execute(notification)
    print("-------------->PIGameStationCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()
    if name == MyGameConstants.GAME_STATION then
        data.GameStationData = body
        if body.v_bIsauto ~= nil then
            local bAutoTab = body.v_bIsauto
            for i = 0, 3 do
                if i == GameUtils:getInstance():getSelfServerChair() then
                    data.IsAuto = bAutoTab[i + 1]
                end
            end
        end
    end
end

return PIGameStationCommand