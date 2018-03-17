
local MacroCommand = cc.load("puremvc").MacroCommand
local StartActNotifyCommand = class("StartActNotifyCommand", MacroCommand)

function StartActNotifyCommand:ctor()
	StartActNotifyCommand.super.ctor(self)	
	self:addSubCommand(cc.exports.CPActNotifyCommand)
	self:addSubCommand(cc.exports.OCActNotifyCommand)
    self:addSubCommand(cc.exports.DIActNotifyCommand)
end

return StartActNotifyCommand