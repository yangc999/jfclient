
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local DeskListProxy = class("DeskListProxy", Proxy)

function DeskListProxy:ctor()
	DeskListProxy.super.ctor(self, "DeskListProxy")
end

function DeskListProxy:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	local data = ProxyData.new()
	data:prop("roomId", 0)
	data:prop("lv", 1)
	data:prop("entry", 0)
	data:prop("deskNum", 6)
	data:prop("playerNum", 4)
	data:prop("deskList", {})
	data:prop("showFrom", 0)
	data:prop("showTo", 0)
	data:prop("showDesk", {}, platformFacade, PlatformConstants.UPDATE_SHOWDESK)
	self:setData(data)
end

function DeskListProxy:onRemove()
end

function DeskListProxy:present()
	local show = {}
	for i=self:getData().showFrom,self:getData().showTo do
		table.insert(show, self:getData().deskList[i])
	end
	self:getData().showDesk = show
end

return DeskListProxy