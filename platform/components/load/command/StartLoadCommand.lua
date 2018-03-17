
local MacroCommand = cc.load("puremvc").MacroCommand
local StartLoadCommand = class("StartLoadCommand", MacroCommand)

function StartLoadCommand:ctor()
	StartLoadCommand.super.ctor(self)	
	self:addSubCommand(cc.exports.InitConfigCommand)
	--self:addSubCommand(cc.exports.RequestConfigCommand) --在loadMediator里会执行RequestConfigCommand，没必要请求两次
end

return StartLoadCommand