
local MacroCommand = cc.load("puremvc").MacroCommand
local StartActInfoCommand = class("StartActInfoCommand", MacroCommand)

function StartActInfoCommand:ctor()
	StartActInfoCommand.super.ctor(self)	
	self:addSubCommand(cc.exports.CPActInfoCommand)
	self:addSubCommand(cc.exports.OCActInfoCommand)
    self:addSubCommand(cc.exports.HCActInfoCommand)
end

return StartActInfoCommand