--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local MsgBoxData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local MsgBoxProxy = class("MsgBoxProxy", Proxy)

function MsgBoxProxy:ctor()
	MsgBoxProxy.super.ctor(self, "MsgBoxProxy")
end

function MsgBoxProxy:onRegister()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local GameConstants = cc.exports.GameConstants
    local data = MsgBoxData.new()  --公告所用的数据部分

    data:prop("code", -1)  --MsgBox的标识码
    
	self:setData(data)
end

function MsgBoxProxy:onRemove()
end

return MsgBoxProxy

--endregion
