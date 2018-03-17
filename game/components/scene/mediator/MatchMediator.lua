
local Mediator = cc.load("puremvc").Mediator
local MatchMediator = class("MatchMediator", Mediator)

function MatchMediator:ctor()
	MatchMediator.super.ctor(self, "MatchMediator")
end

function MatchMediator:listNotificationInterests()
	local GameConstants = cc.exports.GameConstants
	return {
		GameConstants.RECV_SOCKET, 
		GameConstants.CONN_SOCKET, 
		GameConstants.FAIL_SOCKET, 
		GameConstants.EXIT_GAME
	}
end

function MatchMediator:onRegister()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    gameFacade:registerCommand(GameConstants.START_WAITRISE, cc.exports.StartWaitRiseCommand)
    gameFacade:registerCommand(GameConstants.REQUEST_ELIMINATE, cc.exports.RequestEliminateCommand)
end

function MatchMediator:onRemove()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	gameFacade:removeCommand(GameConstants.START_WAITRISE)
    gameFacade:removeCommand(GameConstants.START_ELIMINATE)
	gameFacade:removeProxy("GameRoomProxy")
end

function MatchMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local GameConstants = cc.exports.GameConstants
	local PlatformConstants = cc.exports.PlatformConstants
	if name == GameConstants.CONN_SOCKET then
    elseif name == GameConstants.REMOVE_ELIMINATE then
        if gameFacade:retrieveMediator("EliminateMediator") then
           gameFacade:removeMediator("EliminateMediator")
        end
	elseif name == GameConstants.RECV_SOCKET then
		local tp, msg
		if body.vecMsgHead[1] and body.vecMsgHead[1].nMsgType ~= 0 then
			tp = body.vecMsgHead[1].nMsgID
			msg = body.vecMsgData[1]
		end
		local tarslib = cc.load("jfutils").Tars
        if tp == 413 then
            local _, resp = tarslib.decode(msg, "JFGameClientProto::TKOMsgRespRank")
				if not gameFacade:hasProxy("WaitingRiseProxy") then
					gameFacade:sendNotification(GameConstants.START_WAITRISE)
				end
                local waitRise=gameFacade:retrieveProxy("WaitingRiseProxy")
                waitRise:getData().respMsg=resp
                dump(resp, "TKOMsgRespRank")
        elseif tp == 415 then
        print("415415415")
        local _, resp = tarslib.decode(msg, "JFGameClientProto::TKOMsgRespKnockOut")
                 if not gameFacade:hasProxy("EliminateProxy") then
					gameFacade:registerProxy(EliminateProxy.new())
				 end
                 dump(resp,"415415415",10)
                 local eliminateData=gameFacade:retrieveProxy("EliminateProxy")
                 eliminateData:getData().rankMsg=resp
				 gameFacade:sendNotification(GameConstants.REQUEST_ELIMINATE,{matchId=resp.sMatchNo,rank=resp.iRanking})
		end
        elseif name == GameConstants.EXIT_GAME then
               if platformFacade:hasMediator("CompetitionListMediator") then
			      platformFacade:removeMediator("CompetitionListMediator")
				end
	end
end

return MatchMediator