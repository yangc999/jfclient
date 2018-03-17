
local MacroCommand = cc.load("puremvc").MacroCommand
local StartGetTokenCommand = class("StartGetTokenCommand", MacroCommand)

function StartGetTokenCommand:ctor()
	StartGetTokenCommand.super.ctor(self)
    self:addSubCommand(cc.exports.DIGetTokenCommand)	
	self:addSubCommand(cc.exports.HCGetTokenCommand)
end

return StartGetTokenCommand