
local MacroCommand = cc.load("puremvc").MacroCommand
local StartOutCardCommand = class("StartOutCardCommand", MacroCommand)

function StartOutCardCommand:ctor()
	StartOutCardCommand.super.ctor(self)	
	self:addSubCommand(cc.exports.HCOutCardCommand)
	self:addSubCommand(cc.exports.OCOutCardCommand)

end

return StartOutCardCommand