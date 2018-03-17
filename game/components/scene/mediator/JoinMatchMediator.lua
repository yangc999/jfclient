
local Mediator = cc.load("puremvc").Mediator
local JoinMatchMediator = class("JoinMatchMediator", Mediator)
local EliminateProxy = import("..proxy.EliminateProxy")

function JoinMatchMediator:ctor()
	JoinMatchMediator.super.ctor(self, "JoinMatchMediator")
end

function JoinMatchMediator:listNotificationInterests()
	local GameConstants = cc.exports.GameConstants
	return {
		GameConstants.RECV_SOCKET, 
		GameConstants.CONN_SOCKET, 
		GameConstants.FAIL_SOCKET, 
	}
end

function JoinMatchMediator:onRegister()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    gameFacade:registerCommand(GameConstants.START_WAITRISE, cc.exports.StartWaitRiseCommand)
    gameFacade:registerCommand(GameConstants.REQUEST_ELIMINATE, cc.exports.RequestEliminateCommand)
end

function JoinMatchMediator:onRemove()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    if gameFacade:hasProxy("GameRoomProxy") then
        gameFacade:removeProxy("GameRoomProxy")
    end
end

function JoinMatchMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local GameConstants = cc.exports.GameConstants
	local PlatformConstants = cc.exports.PlatformConstants
	if name == GameConstants.CONN_SOCKET then
		
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
		elseif tp == 402 then
            local _, resp = tarslib.decode(msg, "JFGameClientProto::TKOMsgRespJoinMatch")
            dump(resp, "JoinMatch")
        	if resp.iResultID == 0 then
            	platformFacade:sendNotification(PlatformConstants.UPDATE_COMPETITIONBMSTATE,{matchId=resp.iMatchID,types=true})
            	platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "报名成功")
                platformFacade:retrieveProxy("CompetitionListProxy"):getData().JoinMatchId=resp.iMatchID
            elseif resp.iResultID == 801 then
            	platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "比赛人数已经满")
            elseif resp.iResultID == 802 then
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "您已经报过名了")
            	platformFacade:sendNotification(PlatformConstants.UPDATE_COMPETITIONBMSTATE,{matchId=resp.iMatchID,types=true})
            elseif resp.iResultID == 803 then
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "您已经报名了其他比赛")
--            	platformFacade:sendNotification(PlatformConstants.UPDATE_COMPETITIONBMSTATE,{matchId=resp.iMatchID,types=true})
        	end
        elseif tp == 405 then
            local _, resp = tarslib.decode(msg, "JFGameClientProto::TKOMsgRespExitMatch")
            dump(resp, "QuitMatch")
        	if resp.iResultID == 0 then
               -- platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "退赛成功")
               -- platformFacade:sendNotification(PlatformConstants.UPDATE_COMPETITIONBMSTATE,{matchId=resp.iMatchID,types=false})

               local tMsg = {mType = 1, code = 1, msg = "退赛成功"}
                --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
               platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX_EX, tMsg) 
               platformFacade:sendNotification(PlatformConstants.UPDATE_COMPETITIONBMSTATE,{matchId=resp.iMatchID,types=false})
            end
            if resp.iResultID == 902 then
               platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX, "已经晋级，不能退赛")
            end
        elseif tp == 411 or tp == 412 then
            -- 下一轮删除上一轮的等待界面
            if gameFacade:hasMediator("WaitingRiseMediator") then
                gameFacade:removeMediator("WaitingRiseMediator")
            end

        	local _, resp = tarslib.decode(msg, "JFGameClientProto::TKOMsgRespSitDown")
        	dump(resp, "SitResp")
			if not gameFacade:hasMediator("SceneMediator") then
				gameFacade:sendNotification(GameConstants.START_GAME)
                if platformFacade:hasMediator("CompetitionListMediator") then
                   platformFacade:removeMediator("CompetitionListMediator")
                   platformFacade:sendNotification(PlatformConstants.CLOSE_MSGBOX)
                end
			end
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
        elseif tp == 413 then
			local _, resp = tarslib.decode(msg, "JFGameClientProto::TKOMsgRespRank")
            dump(resp, "TKOMsgRespRank")
            local data = gameFacade:retrieveProxy("GameRoomProxy"):getData()
            data.matchData = resp

--			if not gameFacade:hasProxy("WaitingRiseProxy") then
--				gameFacade:sendNotification(GameConstants.START_WAITRISE)
--			end
--			local waitRise = gameFacade:retrieveProxy("WaitingRiseProxy")
--			waitRise:getData().respMsg = resp
--			dump(resp, "TKOMsgRespRank")
        elseif tp == 414 then
			local _, resp = tarslib.decode(msg, "JFGameClientProto::TKOMsgRespRise")
			if not gameFacade:hasProxy("WaitingRiseProxy") then
				gameFacade:sendNotification(GameConstants.START_WAITRISE)
			end
			local waitRise = gameFacade:retrieveProxy("WaitingRiseProxy")
			waitRise:getData().respMsg = resp
			dump(resp, "TKOMsgRespRank")
        elseif tp == 415 then
        	local _, resp = tarslib.decode(msg, "JFGameClientProto::TKOMsgRespKnockOut")
			if not gameFacade:hasProxy("EliminateProxy") then
			    gameFacade:registerProxy(EliminateProxy.new())
			end
			local eliminateData = gameFacade:retrieveProxy("EliminateProxy")
			eliminateData:getData().rankMsg = resp
			gameFacade:sendNotification(GameConstants.REQUEST_ELIMINATE,{sMatchNo=resp.sMatchNo,rank=resp.iRanking})
        elseif tp == 417 then
            local _, resp = tarslib.decode(msg, "JFGameClientProto::TKOMsgRespCheckMatch")
            dump(resp, "TKOMsgRespCheckMatch")
        	if resp.iResultID == 0 then
               platformFacade:retrieveProxy("CompetitionListProxy"):getData().JoinMatchId=resp.iMatchID
               platformFacade:sendNotification(PlatformConstants.UPDATE_COMPETITIONBMSTATE,{matchId=resp.iMatchID,types=true})
            end
        end
	end
end

return JoinMatchMediator