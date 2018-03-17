
local MacroCommand = cc.load("puremvc").MacroCommand
local StartGameCommand = class("StartGameCommand", MacroCommand)

function StartGameCommand:ctor()
	StartGameCommand.super.ctor(self)
    print("StartGameCommand")
	self:addSubCommand(cc.exports.StartSceneCommand)
	self:addSubCommand(cc.exports.StartChatCommand)
	self:addSubCommand(cc.exports.StartVoiceCommand)
	self:addSubCommand(cc.exports.StartLocationCommand)
	self:addSubCommand(cc.exports.StartDeskCommand)
	self:addSubCommand(cc.exports.StartLoadGameCommand)
end

return StartGameCommand