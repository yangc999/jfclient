
local SimpleCommand = cc.load("puremvc").SimpleCommand
local SubChoiceCommand = class("SubChoiceCommand", SimpleCommand)

function SubChoiceCommand:execute(notification)
	local body = notification:getBody()
	local tp = notification:getType()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")	
	local roomCfg = platformFacade:retrieveProxy("RoomConfigProxy")
	local backup = clone(roomCfg:getData().choice)
	for i,v in ipairs(backup) do
		if v.id == tp then
			table.removebyvalue(v.choice, body)
		end
	end	
	roomCfg:getData().choice = backup
end

return SubChoiceCommand