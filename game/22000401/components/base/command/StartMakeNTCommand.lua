
local MacroCommand = cc.load("puremvc").MacroCommand
local StartMakeNTCommand = class("StartMakeNTCommand", MacroCommand)

function StartMakeNTCommand:ctor()
	StartMakeNTCommand.super.ctor(self)	
	self:addSubCommand(cc.exports.PIMakeNTCommand)
	self:addSubCommand(cc.exports.DIMakeNtCommand)

end

return StartMakeNTCommand