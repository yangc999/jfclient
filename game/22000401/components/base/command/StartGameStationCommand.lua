
local MacroCommand = cc.load("puremvc").MacroCommand
local StartGameStationCommand = class("StartGameStationCommand", MacroCommand)

function StartGameStationCommand:ctor()
	StartGameStationCommand.super.ctor(self)	
	self:addSubCommand(cc.exports.CPGameStationCommand)
	self:addSubCommand(cc.exports.DIGameStationCommand)
    self:addSubCommand(cc.exports.HCGameStationCommand)
    self:addSubCommand(cc.exports.MEGameStationCommand)
    self:addSubCommand(cc.exports.OCGameStationCommand)
    self:addSubCommand(cc.exports.PIGameStationCommand)
end

return StartGameStationCommand