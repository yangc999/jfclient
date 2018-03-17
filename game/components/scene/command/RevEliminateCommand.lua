local SimpleCommand = cc.load("puremvc").SimpleCommand
local RevEliminateCommand = class("RevEliminateCommand", SimpleCommand)
local JoinMatchMediator = import("..mediator.JoinMatchMediator")
local GameRoomProxy = import("..proxy.GameRoomProxy") 

function RevEliminateCommand:execute(notification)
	print("RevEliminateCommand")
    local body=notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local list=platformFacade:retrieveProxy("CompetitionListProxy"):getData().templateIdTomatchIdList
	local tarslib = cc.load("jfutils").Tars
	if not gameFacade:hasMediator("JoinMatchMediator") then
    	gameFacade:registerMediator(JoinMatchMediator.new())
    end
    if not gameFacade:hasProxy("GameRoomProxy") then
    	gameFacade:registerProxy(GameRoomProxy.new())
    end
    local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")
    gameRoom:getData().gameId=list[body.templateId].gameId
    gameRoom:getData().roomId="4:0"..list[body.templateId].startMode..":"..list[body.templateId].gameId
	local pak1 = {
		iMatchID = list[body.templateId].matchId,
	}
    print(list[body.templateId].matchId,"iMatchIDssfd")
	local req1 = tarslib.encode(pak1, "JFGameClientProto::TKOMsgReqExitMatch")
	gameFacade:sendNotification(GameConstants.SEND_SOCKET, req1, 404)
end

return RevEliminateCommand