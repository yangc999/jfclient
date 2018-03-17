
local SimpleCommand = cc.load("puremvc").SimpleCommand
local LoopCheckCommand = class("LoopCheckCommand", SimpleCommand)

function LoopCheckCommand:execute(notification)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local scene = platformFacade:retrieveMediator("HallMediator").scene
	local shop = platformFacade:retrieveProxy("ShopProxy")
	--if not shop:getData().loop then
	--	shop:getData().loop = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
	--		platformFacade:sendNotification("check", shop:getData().curOrder)
	--	end, 1, false)
	--end
end

return LoopCheckCommand