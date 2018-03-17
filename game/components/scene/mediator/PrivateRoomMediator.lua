
local Mediator = cc.load("puremvc").Mediator
local PrivateRoomMediator = class("PrivateRoomMediator", Mediator)

function PrivateRoomMediator:ctor()
	PrivateRoomMediator.super.ctor(self, "PrivateRoomMediator")
end

function PrivateRoomMediator:listNotificationInterests()
	local GameConstants = cc.exports.GameConstants
	return {
		GameConstants.RECV_SOCKET, 
		GameConstants.CONN_SOCKET, 
		GameConstants.FAIL_SOCKET, 
		GameConstants.EXIT_GAME
	}
end

function PrivateRoomMediator:onRegister()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	gameFacade:registerCommand(GameConstants.REQUEST_PRVLEAVE, cc.exports.RequestPrivateLeaveCommand)
	gameFacade:registerCommand(GameConstants.REQUEST_PRVDISMISS, cc.exports.RequestPrivateDismissCommand)
	gameFacade:registerCommand(GameConstants.REQUEST_STVOTE, cc.exports.RequestStartVoteCommand)
	gameFacade:registerCommand(GameConstants.REQUEST_VOTE, cc.exports.RequestVoteCommand)
	gameFacade:registerCommand(GameConstants.START_VOTE, cc.exports.StartVoteCommand)
	gameFacade:registerCommand(GameConstants.DOWNLOAD_HEAD, cc.exports.DownloadPlayerHeadCommand)
    
	gameFacade:sendNotification(GameConstants.REQUEST_PRVROOM)
end

function PrivateRoomMediator:onRemove()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	gameFacade:removeCommand(GameConstants.REQUEST_PRVLEAVE)
	gameFacade:removeCommand(GameConstants.REQUEST_PRVDISMISS)
	gameFacade:removeCommand(GameConstants.REQUEST_STVOTE)
	gameFacade:removeCommand(GameConstants.REQUEST_VOTE)
	gameFacade:removeCommand(GameConstants.START_VOTE)
	gameFacade:removeCommand(GameConstants.DOWNLOAD_HEAD)

	gameFacade:removeProxy("GameRoomProxy")
end

function PrivateRoomMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local GameConstants = cc.exports.GameConstants
	local PlatformConstants = cc.exports.PlatformConstants
	if name == GameConstants.CONN_SOCKET then
		gameFacade:sendNotification(GameConstants.REQUEST_PRVROOM)
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
		elseif tp == 102 then
			local _, resp = tarslib.decode(msg, "JFGameClientProto::TPMsgRespEnterRoom")
			dump(resp, "RoomResp")
            cc.exports.hideLoadingAnim()
			if resp.iResultID == 0 then
				local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")
				local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
				local login = platformFacade:retrieveProxy("LoginProxy")
				gameRoom:getData().gameId = body.iGameID
				gameRoom:getData().roomId = body.sRoomID
				gameRoom:getData().serverId = body.iRoomServerID
				gameRoom:getData().masterId = resp.lMasterID

				cc.UserDefault:getInstance():setStringForKey(string.format("roomId_%d", login:getData().uid), body.sRoomID)
				cc.UserDefault:getInstance():setIntegerForKey(string.format("serverId_%d", login:getData().uid), body.iRoomServerID)
				
				gameFacade:sendNotification(GameConstants.START_GAME)

				platformFacade:sendNotification(PlatformConstants.DISMISS_CREATE_ROOM)  --创建房间完成后删掉创建房间配置界面的对话
				print("创建房间完成后删掉创建房间配置界面的对话框")
                platformFacade:removeMediator("JoinRoomMediator")	
			else
				if resp.iResultID == 3 then
					platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "玩家在其它房间")
				elseif resp.iResultID == 4 then
					platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "金币不足")
				elseif resp.iResultID == 101 then
					platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "房间号输入错误")
				elseif resp.iResultID == 102 then
					platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "房间已经解散")
				elseif resp.iResultID == 103 then
					platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "房卡不够")
				elseif resp.iResultID == 105 then
					platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "防作弊房间")
				elseif resp.iResultID == 106 then
					platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "房间已满")
				else
					platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "进入房间失败")
				end
				gameFacade:sendNotification(GameConstants.EXIT_GAME)	
                platformFacade:sendNotification(PlatformConstants.CLR_ROOMKEY)
			end
		elseif tp == 105 or tp == 106 then
			local _, resp = tarslib.decode(msg, "JFGameClientProto::TPMsgRespExitRoom")
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
		elseif tp == 108 or tp == 109 then
			local _, resp = tarslib.decode(msg, "JFGameClientProto::TPMsgRespSitDown")
			dump(resp, "SitResp")
			gameFacade:sendNotification(GameConstants.PENETRATE_MSG, resp, 109)
			if resp.iResultID == 0 then
				local desk = gameFacade:retrieveProxy("DeskProxy")
				local player = clone(desk:getData().player)
				local id = tonumber(resp.sHeadID) or 0
				local img = string.format("%s%d.png", id < 6 and "boy" or "girl", id < 6 and id or id-6)
				local path = "platform_res/common/" .. img
				if resp.sHeadStr and string.len(resp.sHeadStr) then
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
				local login = platformFacade:retrieveProxy("LoginProxy")
				if resp.lPlayerID == login:getData().uid then
					gameFacade:sendNotification(GameConstants.EXIT_GAME)
				end
			end
		elseif tp == 114 then
            --不用处理，发送113时发送了115
			local _, resp = tarslib.decode(msg, "JFGameClientProto::TPMsgRespVoteDismiss")
			dump(resp, "VoteResp")
		elseif tp == 116 then
			local _, resp = tarslib.decode(msg, "JFGameClientProto::TPMsgRespVoteResult")
			dump(resp, "VoteNotify")
			if resp.iResultID == 0 then
				if not gameFacade:hasProxy("VoteProxy") then
					gameFacade:sendNotification(GameConstants.START_VOTE)
				end
				local vote = gameFacade:retrieveProxy("VoteProxy")
				local result = clone(vote:getData().result)
				if resp.iResultID == 0 then
					table.insert(resp.bAgreeDismiss and result.agree or result.refuse, resp.lPlayerID)
                    if #result.agree == 1 then
                        result.dismisman = resp.lPlayerID
                    end
					vote:getData().result = result
				end
			end
		elseif tp == 117 or tp == 118 then
			gameFacade:sendNotification(GameConstants.END_VOTE)
			local _, resp = tarslib.decode(msg, "JFGameClientProto::TPMsgRespDismissRoom")
			dump(resp, "DismissResp")			
			if resp.iResultID == 0 then
                local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")
                if gameRoom:getData().gameState == 0 then
                    gameFacade:sendNotification(GameConstants.EXIT_GAME)
                end
			end
		elseif tp == 120 or tp == 121 then
			local _, resp = tarslib.decode(msg, "JFGameClientProto::TPMsgRespChat")
			if resp.iResultID == 0 then
				local chat = gameFacade:retrieveProxy("ChatProxy")
			end
		elseif tp == 123 or tp == 124 then
			local _, resp = tarslib.decode(msg, "JFGameClientProto::TPMsgRespAudioChat")
			if resp.iResultID == 0 then
				local chat = gameFacade:retrieveProxy("ChatProxy")
			end
		end
	elseif name == GameConstants.EXIT_GAME then
		gameFacade:removeMediator("PrivateRoomMediator")
	end
end

return PrivateRoomMediator