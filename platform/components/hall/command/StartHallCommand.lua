
local MacroCommand = cc.load("puremvc").MacroCommand
local StartHallCommand = class("StartHallCommand", MacroCommand)

function StartHallCommand:ctor()
    print("StartHallCommand:ctor")
	StartHallCommand.super.ctor(self)	
	self:addSubCommand(cc.exports.StartUserInfoCommand)
    self:addSubCommand(cc.exports.StartBenefitsCommand)
    self:addSubCommand(cc.exports.StartShopProxyCommand)
	self:addSubCommand(cc.exports.ShowHallCommand)
	self:addSubCommand(cc.exports.RequestUserInfoCommand)
    self:addSubCommand(cc.exports.RequestUserPerfectInfoCommand) --请求用户完善信息
	self:addSubCommand(cc.exports.RequestGameListCommand)
    self:addSubCommand(cc.exports.RequestHorselampCommand)
    self:addSubCommand(cc.exports.RequestBenefitsConfigCommand)
    self:addSubCommand(cc.exports.RequestTaskShareConfigCommand) --请求任务分享的配置
    self:addSubCommand(cc.exports.StartFirstShowAnnounceCommand) --启动大厅时要请求公告列表
end

return StartHallCommand