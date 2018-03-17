
local MacroCommand = cc.load("puremvc").MacroCommand
local StartCurSameCardCommand = class("StartCurSameCardCommand", MacroCommand)

function StartCurSameCardCommand:ctor()
	StartCurSameCardCommand.super.ctor(self)	
    self:addSubCommand(cc.exports.HCCurSameCardCommand)
	self:addSubCommand(cc.exports.OCCurSameCardCommand)
end

return StartCurSameCardCommand