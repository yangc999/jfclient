
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local VoteProxy = class("VoteProxy", Proxy)

function VoteProxy:ctor()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants

	VoteProxy.super.ctor(self, "VoteProxy")

	local data = ProxyData.new()
	data:prop("result", {agree={}, refuse={}, dismisman}, gameFacade, GameConstants.UPDATE_VOTE)
	self:setData(data)
end

function VoteProxy:onRegister()
end

function VoteProxy:onRemove()
end

function VoteProxy:getResult(uid)
	local data = self:getData().result
	local result = "等待选择"
	if table.indexof(data.agree, uid) then
		result = "接受"
	elseif table.indexof(data.refuse, uid) then
		result = "拒绝"
	end
	return result
end

function VoteProxy:getVoteman()
    local data = self:getData().result
    return data.dismisman
end

return VoteProxy