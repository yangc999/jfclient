
local Mediator = cc.load("puremvc").Mediator
local FreeRoomMediator = class("FreeRoomMediator", Mediator)

function FreeRoomMediator:ctor()
	FreeRoomMediator.super.ctor(self, "FreeRoomMediator")
end

function FreeRoomMediator:listNotificationInterests()
	local GameConstants = cc.exports.GameConstants
	return {
		GameConstants.RECV_SOCKET, 
		GameConstants.CONN_SOCKET, 
		GameConstants.FAIL_SOCKET, 
		GameConstants.EXIT_GAME
	}
end

function FreeRoomMediator:onRegister()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	gameFacade:registerCommand(GameConstants.DOWNLOAD_HEAD, cc.exports.DownloadPlayerHeadCommand)
end

function FreeRoomMediator:onRemove()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	gameFacade:removeCommand(GameConstants.DOWNLOAD_HEAD)

	gameFacade:removeProxy("GameRoomProxy")
end

function FreeRoomMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local GameConstants = cc.exports.GameConstants
	local PlatformConstants = cc.exports.PlatformConstants
	if name == GameConstants.CONN_SOCKET then
		gameFacade:sendNotification(GameConstants.REQUEST_QUKQUEUE)
	elseif name == GameConstants.RECV_SOCKET then
		local tp, msg
		if body.vecMsgHead[1] and body.vecMsgHead[1].nMsgType ~= 0 then
			tp = body.vecMsgHead[1].nMsgID
			msg = body.vecMsgData[1]
		end
		local tarslib = cc.load("jfutils").Tars
		if tp == 2 or tp == 3 then
			gameFacade:sendNotification(GameConstants.PENETRATE_MSG, msg, 3)
		elseif tp == 96 then
            local _, resp = tarslib.decode(msg, "JFGameClientProto::TMsgRespOffline")
            dump(resp, "OffResp")
            gameFacade:sendNotification(GameConstants.PENETRATE_MSG, resp, 96)
		elseif tp == 97 then
            local _, resp = tarslib.decode(msg, "JFGameClientProto::TMsgRespRecome")
            dump(resp, "RecomeResp")
            gameFacade:sendNotification(GameConstants.PENETRATE_MSG, resp, 97)
        elseif tp == 202 or tp == 203 then
        	local _, resp = tarslib.decode(msg, "JFGameClientProto::TFSMsgRespEnterRoom")
        	dump(resp, "enterResp")
        	if resp.iResultID == 0 then
				gameFacade:sendNotification(GameConstants.START_GAME)
				gameFacade:sendNotification(GameConstants.REQUEST_FRESIT, resp.iTableID)
        	else
        		gameFacade:sendNotification(GameConstants.EXIT_GAME)
        	end
		elseif tp == 205 or tp == 206 then
			local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")	
			if gameRoom:getData().serverId ~= body.iRoomServerID then
				gameRoom:getData().serverId = body.iRoomServerID
			end

			local _, resp = tarslib.decode(msg, "JFGameClientProto::TFSMsgRespSitDown")
			dump(resp, "SitResp")
			gameFacade:sendNotification(GameConstants.PENETRATE_MSG, resp, 109)
			local login = platformFacade:retrieveProxy("LoginProxy")
			if resp.iResultID == 0 then
				local desk = gameFacade:retrieveProxy("DeskProxy")
				local player = clone(desk:getData().player)
				local id = tonumber(resp.sHeadID) or 0
				local img = string.format("%s%d.png", id < 6 and "boy" or "girl", id < 6 and id or id-6)
				local path = "platform_res/common/" .. img
				if resp.sHeadStr and string.len(resp.sHeadStr) > 0 then
					local url = cc.UserDefault:getInstance():getStringForKey(string.format("%d_url", resp.lPlayerID))
					if resp.sHeadStr ~= url then
						gameFacade:sendNotification(GameConstants.DOWNLOAD_HEAD, resp.sHeadStr, resp.lPlayerID)
					else
						local lpath = cc.UserDefault:getInstance():getStringForKey(string.format("%d_save", resp.lPlayerID))
						if lpath and cc.FileUtils:getInstance():isFileExist(localpath) then
							path = lpath
						else
							gameFacade:sendNotification(GameConstants.DOWNLOAD_HEAD, resp.sHeadStr, resp.lPlayerID)
						end
					end
				end

				player[resp.iChairID] = {
					name = resp.sNickName, 
					uid = resp.lPlayerID, 
					head = path, 
					gender = resp.iPlayerGender, 
					state = resp.ePlayerState, 
				}
				dump(player, "player")
				desk:getData().player = player		
			else
				local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
				if resp.lPlayerID == login:getData().uid then
					gameFacade:sendNotification(GameConstants.EXIT_GAME)
				end
			end
		elseif tp == 208 or tp == 209 then
			local _, resp = tarslib.decode(msg, "JFGameClientProto::TFSMsgRespExit")
			dump(resp, "ExitResp")
			gameFacade:sendNotification(GameConstants.PENETRATE_MSG, resp, 105)
			if resp.iResultID == 0 then
				local desk = gameFacade:retrieveProxy("DeskProxy")
				local player = clone(desk:getData().player)
				player[resp.iChairID] = nil
				desk:getData().player = player
				local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
				local login = platformFacade:retrieveProxy("LoginProxy")				
				if resp.lPlayerID == login:getData().uid then
					cc.UserDefault:getInstance():deleteValueForKey(string.format("roomId_%d", login:getData().uid))
					cc.UserDefault:getInstance():deleteValueForKey(string.format("serverId_%d", login:getData().uid))					
					gameFacade:sendNotification(GameConstants.EXIT_GAME)
				end
			end
		end
	elseif name == GameConstants.EXIT_GAME then
		gameFacade:removeMediator("FreeRoomMediator")
	end
end

return FreeRoomMediator