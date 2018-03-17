
local SettingMediator = import("..mediator.SettingMediator")
local SimpleCommand = cc.load("puremvc").SimpleCommand
local SettingCommand = class("SettingCommand", SimpleCommand)

function SettingCommand:execute(notification)
    print("-------------->SettingCommand:execute")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	gameFacade:registerMediator(SettingMediator.new())
end

return SettingCommand