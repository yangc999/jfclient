
local JFSocket = cc.load("jfutils").JFSocket
local ByteArray = cc.load("jfutils").ByteArray

local Mediator = cc.load("puremvc").Mediator
local TcpMediator = class("TcpMediator", Mediator)

function TcpMediator:ctor()
	TcpMediator.super.ctor(self, "TcpMediator")
	self.buffer = ""
end

function TcpMediator:listNotificationInterests()
	local GameConstants = cc.exports.GameConstants
	return {
		GameConstants.SEND_SOCKET, 
	}
end

function TcpMediator:onRegister()
	local tarslib = cc.load("jfutils").Tars
	local path1 = cc.FileUtils:getInstance():fullPathForFilename("game/components/scene/tars/JFGameClientProto.tars")
	tarslib.register(path1)
	local path2 = cc.FileUtils:getInstance():fullPathForFilename("game/components/scene/tars/JFGameSoProto.tars")
	tarslib.register(path2)

	self.client = JFSocket.new() 
	self.client:addEventListener(JFSocket.EVENT_CONNECTED, handler(self, self.onConn))
	self.client:addEventListener(JFSocket.EVENT_CONNECT_FAILURE, handler(self, self.onFail))
	self.client:addEventListener(JFSocket.EVENT_CLOSE, handler(self, self.onClose))
	self.client:addEventListener(JFSocket.EVENT_CLOSED, handler(self, self.onClosed))
	self.client:addEventListener(JFSocket.EVENT_DATA, handler(self, self.onRecv))

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local load = platformFacade:retrieveProxy("LoadProxy")
	print(load:getData().serverIp, load:getData().serverPort)
	self.client:connect(load:getData().serverIp, load:getData().serverPort, true)
end

function TcpMediator:onRemove()
	print("tcp release")
	self.client:disconnect()
	self.client:close()
end

function TcpMediator:handleNotification(notification)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	if name == GameConstants.SEND_SOCKET then
		local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")
		local login = platformFacade:retrieveProxy("LoginProxy")
		local uid = login:getData().uid
		local token = login:getData().token
		local gameId = gameRoom and gameRoom:getData().gameId or 0
		local roomId = gameRoom and gameRoom:getData().roomId or ""
		local serverId = gameRoom and gameRoom:getData().serverId or 0
		local tarslib = cc.load("jfutils").Tars
		if body then
			local pak = {
				iVersion = 0,
				stUid = {
					lUid = uid, 
					sToken = token, 
				}, 
				iGameID = gameId, 
				sRoomID = roomId, 
				iRoomServerID = serverId, 
				iSequence = 0, 
				iFlag = 0, 
				vecMsgHead = {
					{nMsgID = tp, nMsgType = 0,} 
				}, 
				vecMsgData = {
					body, 
				}, 
			}
			dump(pak, "pak")
			local str = tarslib.encode(pak, "JFGameClientProto::TPackage")
			local msg = string.pack(">hA", string.len(str)+2, str)
			self.client:send(msg)
		end
	end
end

function TcpMediator:onConn(evt)
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	gameFacade:sendNotification(GameConstants.CONN_SOCKET)
end

function TcpMediator:onFail(evt)
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	gameFacade:sendNotification(GameConstants.FAIL_SOCKET)
end

function TcpMediator:onClose(evt)
	print("tcp close")
end

function TcpMediator:onClosed(evt)
	print("tcp closed")
end

function TcpMediator:onRecv(evt)
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants

	if evt.data and string.len(evt.data) > 0 then
		self.buffer = self.buffer .. evt.data
		while string.len(self.buffer) >= 2 do
			local _, length = string.unpack(self.buffer, ">h")
			length = length - 2
			if string.len(self.buffer) - 2 >= length then
				local tarslib = cc.load("jfutils").Tars
				local package = string.sub(self.buffer, 3, length+2)
				self.buffer = string.sub(self.buffer, length+3)
				local _, msg = tarslib.decode(package, "JFGameClientProto::TPackage")
				if msg then
					dump(msg, "recvMsg")
					gameFacade:sendNotification(GameConstants.RECV_SOCKET, msg)
				end
			else
				break
			end
		end
	end
end

return TcpMediator