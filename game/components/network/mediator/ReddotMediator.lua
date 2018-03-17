
local Mediator = cc.load("puremvc").Mediator
local ReddotMediator = class("ReddotMediator", Mediator)

function ReddotMediator:ctor()
	ReddotMediator.super.ctor(self, "ReddotMediator")
end

function ReddotMediator:listNotificationInterests()
	local GameConstants = cc.exports.GameConstants
	return {
		GameConstants.CONN_SOCKET, 
		GameConstants.RECV_SOCKET, 
	}
end

function ReddotMediator:onRegister()
	local tarslib = cc.load("jfutils").Tars
	local path = cc.FileUtils:getInstance():fullPathForFilename("game/components/network/tars/TipTcpProto.tars")
	tarslib.register(path)
end

function ReddotMediator:onRemove()
end

function ReddotMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local GameConstants = cc.exports.GameConstants
	local PlatformConstants = cc.exports.PlatformConstants

	local msgNotificationMap = {
		[0] = PlatformConstants.UPDATE_USERWEALTH, 
	}

	if name == GameConstants.CONN_SOCKET then
		gameFacade:sendNotification(GameConstants.SEND_SOCKET, "", 99)
	elseif name == GameConstants.RECV_SOCKET then
		local tp, msg
		if body.vecMsgHead[1] and body.vecMsgHead[1].nMsgType ~= 0 then
			tp = body.vecMsgHead[1].nMsgID
			msg = body.vecMsgData[1]
		end
		local tarslib = cc.load("jfutils").Tars
		if tp == 0 then
			print("Reddot Msg Invoke")
			local _, resp = tarslib.decode(msg, "tip::TTipMsg")
			dump(resp, "reddot")
			if resp and msgNotificationMap[resp.eMsgID] then
				platformFacade:sendNotification(msgNotificationMap[resp.eMsgID])
			end
		end

	end
end

return ReddotMediator