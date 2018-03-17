CompetitionListMediator=class("CompetitionListMediator",cc.load("puremvc").Mediator)

function CompetitionMediator:ctor()
	CompetitionMediator.super.ctor(self, "CompetitionMediator")
end	

function CompetitionMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
    PlatformConstants.UPDATE_MATCHGAMELIST,
	}
end

function CompetitionListMediator:onRegister()
    local platformFacade=cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    local ui=cc.CSLoader:createNode("hall_res/competitionList/CompetitionListLayer.csb")
    self.gameList=seekNodeByName(ui,"gameList")
    self.gameListItemTemplet=seekNodeByName(ui,"gameListItemTemplet")
    self.gameIdList={}
    local moreGameBtn=seekNodeByName(ui,"more_game_btn")
    moreGameBtn:addClickEventListener(function()
    platformFacade:sendNotification(PlatformConstants.REQUEST_ANNOUNCEBYID)
    end)

end 

function CompetitionMediator:onRemove()

end

function CompetitionMediator:handleNotification(notification)
    local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local matchProxy = platformFacade:retrieveProxy("MatchProxy")

	if name == PlatformConstants.UPDATE_MATCHGAMELIST then
       local gameListData=matchProxy:getData().gameList
       for i,v in ipairs(gameListData) do
           local item=self.gameListItemTemplet:clone()
           item:setVisible(true)
           self.gameList[i]=v.gameId
           seekNodeByName(item, "gameName"):setString(v.gameName)
           item:addClickEventListener(function()
           platformFacade:sendNotification(PlatformConstants.REQUEST_UPDATEMATCHGAMELIST,v.gameId)
           end)
           self.list:pushBackCustomItem(item)
       end
    
       
    end
end
return CompetitionListMediator

