local CompetitionMoreGameMediator=class("CompetitionMoreGameMediator",cc.load("puremvc").Mediator)

function CompetitionMoreGameMediator:ctor()
   CompetitionMoreGameMediator.super.ctor(self, "CompetitionMoreGameMediator")
end

function CompetitionMoreGameMediator:listNotificationInterests()
   local PlatformConstants = cc.exports.PlatformConstants
   return {
   PlatformConstants.UPDATE_COMPETITIONMOREGAMELIST,
   PlatformConstants.UPDATE_COMPETITIONMOREGAMELISTSELECTED,
   }
end

function CompetitionMoreGameMediator:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    local PlatformConstants = cc.exports.PlatformConstants

	local scene = platformFacade:retrieveMediator("HallMediator").scene
	local ui = cc.CSLoader:createNode("hall_res/competitionList/MoreGameLayer.csb")
	self:setViewComponent(ui)
    self.root=self:getViewComponent()
	scene:addChild(ui)

   self.gameListSelected=seekNodeByName(self.root,"gamelist_selected")
   self.gameList=seekNodeByName(self.root,"gamelist")
   self.gameListSelected:setScrollBarEnabled(false)
   self.gameList:setScrollBarEnabled(false)
   self.gameListItemTempl=seekNodeByName(self.root,"gameItemPanel")
   local quitBtn=seekNodeByName(self.root,"quit_btn")
   quitBtn:addClickEventListener(function()
   self:onQuit()
end)
   local closeBtn=seekNodeByName(self.root,"close_btn")
   closeBtn:addClickEventListener(function()
   self:onQuit()
end)
local cptMoreGameData = platformFacade:retrieveProxy("CptMoreGameProxy")
platformFacade:sendNotification(PlatformConstants.UPDATE_COMPETITIONMOREGAMELIST)
platformFacade:sendNotification(PlatformConstants.UPDATE_COMPETITIONMOREGAMELISTSELECTED)
dump(cptMoreGameData:getData().gameList,"gameListss",10)
--      cptMoreGameData:present()
--    cptMoreGameData:getData().gameList={
--    {id=1,gameid=22000401,gameName="fgg麻将",icon="",selected=false},
--    {id=1,gameid=22000401,gameName="hunan麻将",icon="",selected=false},
--    {id=1,gameid=22000401,gameName="al麻将",icon="",selected=false},
--    {id=1,gameid=22000401,gameName="河南麻将",icon="",selected=false},
--    {id=1,gameid=22000401,gameName="进行麻将",icon="",selected=false},
--    {id=1,gameid=22000401,gameName="发送麻将",icon="",selected=false},
--    {id=1,gameid=22000401,gameName="方法麻将",icon="",selected=false},
--    {id=1,gameid=22000401,gameName="呵呵麻将",icon="",selected=false},
--    {id=1,gameid=22000401,gameName="回家麻将",icon="",selected=false},
--    {id=1,gameid=22000401,gameName="嘎嘎麻将",icon="",selected=false},
--    {id=1,gameid=22000401,gameName="fa麻将",icon="",selected=true},
--    {id=1,gameid=22000401,gameName="sa麻将",icon="",selected=true},
--    {id=1,gameid=22000401,gameName="zz麻将",icon="",selected=true},
--    {id=1,gameid=22000401,gameName="gh麻将",icon="",selected=true},
--    }
--    cptMoreGameData:getData().gameListSelected= {
--    {id=1,gameid=22000401,gameName="fa麻将",icon="",selected=true},
--    {id=1,gameid=22000401,gameName="sa麻将",icon="",selected=true},
--    {id=1,gameid=22000401,gameName="zz麻将",icon="",selected=true},
--    {id=1,gameid=22000401,gameName="gh麻将",icon="",selected=true},
--    }
end

function CompetitionMoreGameMediator:handleNotification(notification)
    local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local cptMoreGameData = platformFacade:retrieveProxy("CptMoreGameProxy"):getData()
    local gameListSelectedTemp={}
    gameListSelectedTemp=cptMoreGameData.gameListSelected
	if name == PlatformConstants.UPDATE_COMPETITIONMOREGAMELISTSELECTED then
      self.gameListSelected:removeAllItems()
      local gameListSelectedlen=#gameListSelectedTemp
      for k=1,gameListSelectedlen do
        local gameListSelecteditem=self.gameListItemTempl:clone()
        self.gameListSelected:pushBackCustomItem(gameListSelecteditem)
        seekNodeByName(gameListSelecteditem, "gameflagW"):setVisible(false) 
        seekNodeByName(gameListSelecteditem, "gameflagX"):setVisible(true)
        seekNodeByName(gameListSelecteditem, "maskbg"):setVisible(false)      
        seekNodeByName(gameListSelecteditem, "gameflagX"):addClickEventListener(function()
        gameListSelectedTemp[k].selected=false
        self:changeData(gameListSelectedTemp[k].gameName)
        table.remove(gameListSelectedTemp,k)
        platformFacade:retrieveProxy("CptMoreGameProxy"):getData().gameListSelected=gameListSelectedTemp
        end)
        seekNodeByName(gameListSelecteditem, "gameName"):setString(gameListSelectedTemp[k].gameName)
        gameListSelecteditem:setVisible(true) 
      end
    end
    if name == PlatformConstants.UPDATE_COMPETITIONMOREGAMELIST then
      local gameListTemp={}
      gameListTemp=clone(cptMoreGameData.gameList)
      self.gameList:removeAllChildren()
      local len=#gameListTemp
      
      for j=1,len  do
        local gameListitem=self.gameListItemTempl:clone()
        seekNodeByName(gameListitem, "gameflagW"):setVisible(true)
        seekNodeByName(gameListitem, "gameflagX"):setVisible(false)
        gameListitem:setTouchEnabled(not gameListTemp[j].selected)
        seekNodeByName(gameListitem, "maskbg"):setVisible(gameListTemp[j].selected)
        seekNodeByName(gameListitem, "maskbg_0"):addClickEventListener(function()
        gameListTemp[j].selected=true
        table.insert(gameListSelectedTemp,gameListTemp[j])
        platformFacade:retrieveProxy("CptMoreGameProxy"):getData().gameListSelected=gameListSelectedTemp
        platformFacade:retrieveProxy("CptMoreGameProxy"):getData().gameList=gameListTemp
        end)
        seekNodeByName(gameListitem, "gameflagW"):addClickEventListener(function()
        end)
        seekNodeByName(gameListitem, "gameName"):setString(gameListTemp[j].gameName)
        gameListitem:setPosition(8+((j-1)%4)*230,380-(math.floor((j-1)/4)*100))
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

function CompetitionMoreGameMediator:changeData(gameName)
   local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
   local cptMoreGameData = platformFacade:retrieveProxy("CptMoreGameProxy"):getData()
   local temp={}
   temp=cptMoreGameData.gameList
   local len =#temp
   for i=1,len do
       if gameName==temp[i].gameName then 
          temp[i].selected=false
          platformFacade:retrieveProxy("CptMoreGameProxy"):getData().gameList=temp
          return
       end
   end
end

function CompetitionMoreGameMediator:onQuit()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    platformFacade:retrieveProxy("CptMoreGameProxy"):saveData()
    platformFacade:removeMediator("CompetitionMoreGameMediator")
end
function CompetitionMoreGameMediator:onRemove()
	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end


return CompetitionMoreGameMediator