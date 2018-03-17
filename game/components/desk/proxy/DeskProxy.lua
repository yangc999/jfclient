
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local DeskProxy = class("DeskProxy", Proxy)

function DeskProxy:ctor()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants

	DeskProxy.super.ctor(self, "DeskProxy")

	local data = ProxyData.new()
	data:prop("player", {}, gameFacade, GameConstants.UPDATE_USER)
	self:setData(data)
end

function DeskProxy:onRegister()
end

function DeskProxy:onRemove()
end

function DeskProxy:getUserId(chair)
	local data = self:getData()
	local uid
	if data[chair] then
		
	end
	return uid
end

function DeskProxy:getHead(chair)
	local data = self:getData()
	local head
	if data[chair] then
		
	end
	return head
end

function DeskProxy:getName(chair)
	local data = self:getData()
	local name
	if data[chair] then
		
	end
	return name
end

return DeskProxy