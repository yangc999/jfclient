
local MacroCommand = cc.load("puremvc").MacroCommand
local TestTcpCommand = class("TestTcpCommand", MacroCommand)

function TestTcpCommand:ctor()
	TestTcpCommand.super.ctor(self)
	self:addSubCommand(cc.exports.TestServerCommand)
	--self:addSubCommand(cc.exports.TestClientCommand)
end

return TestTcpCommand