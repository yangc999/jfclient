local SimpleCommand = cc.load("puremvc").SimpleCommand
local DIGetTokenCommand = class("DIGetTokenCommand", SimpleCommand)

function DIGetTokenCommand:execute(notification)
    print("-------------->DIGetTokenCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
   
    if name == MyGameConstants.GET_TOKEN then
        local image_root = gameFacade:retrieveMediator("MainMediator").image_root
        local delayTime = 0
        if body.eDrawedTile ~= 254 then
            delayTime = 1
        end

        performWithDelay(image_root, function()
            data.TokenData = body
        end , delayTime)
    end
end

return DIGetTokenCommand