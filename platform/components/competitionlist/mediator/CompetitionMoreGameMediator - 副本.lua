local CompetitionMoreGameMediator=class("CompetitionMoreGameMediator",cc.load("puremvc").Mediator)

function CompetitionMoreGameMediator:ctor()
   CompetitionMoreGameMediator.super.ctor(self, "CompetitionMoreGameMediator")
end

function CompetitionMoreGameMediator:listNotificationInterests()
   local PlatformConstants = cc.exports.PlatformConstants
   return {
   PlatformConstants.UPDATE_COMPETITIONMOREGAME,
   }
end

function CompetitionMoreGameMediator:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants

	local scene = platformFacade:retrieveMediator("HallMediator").scene
	local ui = cc.CSLoader:createNode("hall_res/competitionList/MoreGameLayer.csb")
	self:setViewComponent(ui)
    self.root=self:getViewComponent()
	scene:addChild(ui)

   self.gameListSelected=seekNodeByName(self.root,"gamelist_selected")
   self.gameList=seekNodeByName(self.root,"gamelist")
   self.gameListSelected:setScrollBarEnabled(false)
   self.gameList:setScrollBarEnabled(false)
   self.gameListItemTempl=seekNodeByName(self.root,"gameItemTempl")
   print(self.gameListItemTempl,"gameListItemTempl")
   local quitBtn=seekNodeByName(self.root,"quit_btn")
   quitBtn:addClickEventListener(function()
   self:onQuit()
end)
   local closeBtn=seekNodeByName(self.root,"close_btn")
   closeBtn:addClickEventListener(function()
   self:onQuit()
end)
local cptMoreGameData = platformFacade:retrieveProxy("CptMoreGameProxy")
    cptMoreGameData:getData().gameList=     {
    {id=1,gameId=22000401,gameName="fg麻将",icon="",selected=false},
    {id=1,gameId=22000401,gameName="hunan麻将",icon="",selected=false},
    {id=1,gameId=22000401,gameName="广东麻将",icon="",selected=false},
    {id=1,gameId=22000401,gameName="广东麻将",icon="",selected=false},
    {id=1,gameId=22000401,gameName="广东麻将",icon="",selected=false},
    {id=1,gameId=22000401,gameName="广东麻将",icon="",selected=false},
    {id=1,gameId=22000401,gameName="广东麻将",icon="",selected=false},
    {id=1,gameId=22000401,gameName="广东麻将",icon="",selected=false},
    {id=1,gameId=22000401,gameName="广东麻将",icon="",selected=false},
    {id=1,gameId=22000401,gameName="广东麻将",icon="",selected=false},
    }
    cptMoreGameData:getData().gameListSelected= {
    {id=1,gameId=22000401,gameName="fa麻将",icon=""},
    {id=1,gameId=22000401,gameName="sa麻将",icon=""},
    {id=1,gameId=22000401,gameName="zz麻将",icon=""},
    {id=1,gameId=22000401,gameName="广东麻将",icon=""},
    }
end

function CompetitionMoreGameMediator:handleNotification(notification)
    local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.UPDATE_COMPETITIONMOREGAME then
      self.gameListSelected:removeAllItems()
      self.gameListSelected:removeAllChildren()
      local gameListSelectedTemp={}
      local gameListTemp={}
      local cptMoreGameData = platformFacade:retrieveProxy("CptMoreGameProxy"):getData()
      gameListSelectedTemp=cptMoreGameData.gameList
      gameListTemp=cptMoreGameData.gameList
      local gameListSelectedlen=#gameListSelectedTemp
      for k=1,gameListSelectedlen do
      if gameListSelectedTemp[k].selected then
        local gameListSelecteditem=self.gameListItemTempl:clone()
        self.gameListSelected:pushBackCustomItem(gameListSelecteditem)
        seekNodeByName(gameListSelecteditem, "gameflagW"):setVisible(false)
        seekNodeByName(gameListSelecteditem, "gameflagX"):setVisible(true)
        seekNodeByName(gameListSelecteditem, "maskbg"):setVisible(false)      
        seekNodeByName(gameListSelecteditem, "gameflagX"):addClickEventListener(function()
        gameListSelectedTemp[k].selected=false
        platformFacade:retrieveProxy("CptMoreGameProxy"):getData().gameList=gameListSelectedTemp
        end)
        seekNodeByName(gameListSelecteditem, "gameName"):setString(gameListSelectedTemp[k].gameName)
        gameListSelecteditem:setVisible(true) 
        end
      end
      local len=#gameListTemp
      for i=1,len  do
        local gameListitem=self.gameListItemTempl:clone()
        seekNodeByName(gameListitem, "gameflagW"):setVisible(true)
        seekNodeByName(gameListitem, "gameflagX"):setVisible(false)
        gameListitem:setTouchEnabled(not gameListTemp[i].selected)
        seekNodeByName(gameListitem, "maskbg"):setVisible(gameListTemp[i].selected)
        gameListitem:addClickEventListener(function()
        gameListTemp[i].selected=true
        platformFacade:retrieveProxy("CptMoreGameProxy"):getData().gameList=gameListTemp
        end)
        seekNodeByName(gameListitem, "gameflagW"):addClickEventListener(function()
        end)
        seekNodeByName(gameListitem, "gameName"):setString(gameListTemp[i].gameName)
        gameListitem:setPosition(8+((i-1)%4)*230,480-(math.floor((i-1)/4)*100))
        gameListitem:setVisible(true)
        self.gameList:addChild(gameListitem)
      end
    end
end

function CompetitionMoreGameMediator:AddItem(list)
--    local item=self.gameListItemTempl:clone()
--    seekNodeByName(item, "gameflagW"):setVisible(false)
--    seekNodeByName(item, "gameflagX"):setVisible(true)
--    seekNodeByName(item, "maskbg"):setVisible(false)      
--    seekNodeByName(item, "gameflagX"):addClickEventListener(function()
--    self.gameListSelected:removeItem(self.gameListSelected:getIndex(gameListSelecteditem))
--    end)
--    seekNodeByName(gameListSelecteditem, "gameName"):setString(gameListSelected[k].gameName)
--    gameListSelecteditem:setVisible(true)    
end

function CompetitionMoreGameMediator:onQuit()
    
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    platformFacade:removeMediator("CompetitionMoreGameMediator")
end
function CompetitionMoreGameMediator:onRemove()
	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end


return CompetitionMoreGameMediator