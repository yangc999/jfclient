
local DeskInfoMediator = import("..mediator.DeskInfoMediator")
local DeskInfoProxy = import("..proxy.DeskInfoProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local DeskInfoCommand = class("DeskInfoCommand", SimpleCommand)

function DeskInfoCommand:execute(notification)
    print("-------------->DeskInfoCommand:execute")
	local root = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    gameFacade:registerProxy(DeskInfoProxy.new())
	gameFacade:registerMediator(DeskInfoMediator.new(root))

    if GameUtils:getInstance():getGameType() == 1 then
--        local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
--        local choiceConfig = platformFacade:retrieveProxy("RoomConfigProxy"):getData().choice
--        for k, v in pairs(choiceConfig) do
--            if v.code == "Select" then
--                for m, n in pairs(v.choice) do
--                    if n.optionId == 2 then
--                        -- ÊÇ·ñ¹´Ñ¡7¶Ô
--                        local gameFacade = cc.load("puremvc").Facade.getInstance("game")
--                        local data = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
--                        data.IsCan7Dui = true
--                    end
--                end
--            end
--        end
    end
end

return DeskInfoCommand