
local SimpleCommand = cc.load("puremvc").SimpleCommand
local ChangeChoiceCommand = class("ChangeChoiceCommand", SimpleCommand)

function ChangeChoiceCommand:execute(notification)
	local body = notification:getBody()
	local tp = notification:getType()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")	
	local roomCfg = platformFacade:retrieveProxy("RoomConfigProxy")
	local backup = clone(roomCfg:getData().choice)
	for i,v in ipairs(backup) do
		if v.id == tp then
			v.choice = body
		end
	end	
	roomCfg:getData().choice = backup
end

return ChangeChoiceCommand