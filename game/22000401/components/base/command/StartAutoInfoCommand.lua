
local MacroCommand = cc.load("puremvc").MacroCommand
local StartAutoInfoCommand = class("StartAutoInfoCommand", MacroCommand)

function StartAutoInfoCommand:ctor()
	StartAutoInfoCommand.super.ctor(self)	
	self:addSubCommand(cc.exports.PIAutoInfoCommand)
    self:addSubCommand(cc.exports.MEAutoInfoCommand)
end

return StartAutoInfoCommand