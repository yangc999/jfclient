
local MacroCommand = cc.load("puremvc").MacroCommand
local StartLogoutCommand = class("StartLogoutCommand", MacroCommand)

function StartLogoutCommand:ctor()
	StartLogoutCommand.super.ctor(self)
	self:addSubCommand(cc.exports.StartCleanupCommand)
	self:addSubCommand(cc.exports.StartLoginCommand)
end

return StartLogoutCommand