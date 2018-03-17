local CptGameListMediator=class("CptGameListMediator",cc.load("puremvc").Mediator)

function CptGameListMediator:ctor(root)
   CptGameListMediator.super.ctor(self, "CptGameListMediator")
   self.root=root
end

function CptGameListMediator:listNotificationInterests()
   local PlatformConstants = cc.exports.PlatformConstants
   return {
   PlatformConstants.UPDATE_COMPETITIONMOREGAMELISTSELECTED,
   }
end

function CptGameListMediator:onRegister()
    self.gameList = seekNodeByName(self.root, "gameList")
    self.gameListItemTemp = seekNodeByName(self.root, "gamelistItem")
    self.gameList:setScrollBarEnabled(false)
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    platformFacade:sendNotification(PlatformConstants.UPDATE_COMPETITIONMOREGAMELISTSELECTED)

end

function CptGameListMediator:handleNotification(notification)
    local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.UPDATE_COMPETITIONMOREGAMELISTSELECTED then
       local gameList = platformFacade:retrieveProxy("CptMoreGameProxy"):getData().gameListSelected
       platformFacade:registerCommand(PlatformConstants.REQUEST_COMPETITIONLIST,cc.exports.RequestCptListCommand)
       if #gameList>0 then 
       platformFacade:sendNotification(PlatformConstants.REQUEST_COMPETITIONLIST,gameList[1].gameId)
       end
      self.gameList:removeAllItems()

      dump(gameList,"gameList",10)
      for i,v in ipairs(gameList) do
        local gameListitem=self.gameListItemTemp:clone()
        gameListitem:setSelected(false)
        self.gameList:pushBackCustomItem(gameListitem)
        seekNodeByName(gameListitem, "gameName"):setString(v.gameName)
        gameListitem:setVisible(true)
        if i==1 then 
           gameListitem:setTouchEnabled(false)
           gameListitem:setSelected(true)
        end 
      end
    local list=self.gameList:getItems()
    local len=#list
      if list~=nil and len>0 then 
         for i=1,len do
             list[i]:addClickEventListener(function()
             list[i]:setTouchEnabled(false)
             platformFacade:sendNotification(PlatformConstants.REQUEST_COMPETITIONLIST,gameList[i].gameId)
             for k=1,len do
                 if k~=i then
                    list[k]:setTouchEnabled(true)
                    list[k]:setSelected(false)
                 end
             end
             end)
         end
      end
    end
end
function CptGameListMediator:onRemove()
end


return CptGameListMediator