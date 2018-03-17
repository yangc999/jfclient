
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local MainProxy = class("MainProxy", Proxy)

function MainProxy:ctor()
    print("------------>MainProxy:ctor")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local gameConstants = cc.exports.GameConstants

	MainProxy.super.ctor(self, "MainProxy")
	local data = ProxyData.new()
	self:setData(data)
end

function MainProxy:onRegister()
    print("------------>MainProxy:onRegister")
	local tarslib = cc.load("jfutils").Tars
	local path1 = cc.FileUtils:getInstance():fullPathForFilename("game/22000401/components/base/tars/JFGameSoProto.tars")
	tarslib.register(path1)

	local path2 = cc.FileUtils:getInstance():fullPathForFilename("game/22000401/components/base/tars/MJContext.tars")
	tarslib.register(path2)
end

function MainProxy:onRemove()
    print("------------>MainProxy:onRemove")
end

return MainProxy
