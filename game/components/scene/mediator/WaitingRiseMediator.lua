
local Mediator = cc.load("puremvc").Mediator
local WaitingRiseMediator = class("WaitingRiseMediator", Mediator)

function WaitingRiseMediator:ctor()
	WaitingRiseMediator.super.ctor(self, "WaitingRiseMediator")
end

function WaitingRiseMediator:listNotificationInterests()
	local GameConstants = cc.exports.GameConstants
	return {
    GameConstants.UPDATE_WAITINGRISE,
	}
end

function WaitingRiseMediator:onRegister()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    local ui = cc.CSLoader:createNode("game/res/ui_csb/WaitRiseLayer.csb")
    self.rank=seekNodeByName(ui,"rank")
    self.deskNum=seekNodeByName(ui,"deskNum")
    local quitMatchBtn=seekNodeByName(ui,"quitMatch_btn")
    quitMatchBtn:addClickEventListener(function ()
        local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
        local id = 1
        if platformFacade:hasProxy("CompetitionListProxy") then
            id = platformFacade:retrieveProxy("CompetitionListProxy"):getData().templateId
        end
        platformFacade:sendNotification(GameConstants.REQUEST_QUITCOMPETITION,{templateId = id})
        gameFacade:sendNotification(GameConstants.EXIT_GAME)
    end)
    self.roundTempl=seekNodeByName(ui,"roundTempl")

    self:setViewComponent(ui)
	local scene = gameFacade:retrieveMediator("SceneMediator").scene
    gameFacade:sendNotification(GameConstants.UPDATE_WAITINGRISE)
	scene:addChild(ui)
end

function WaitingRiseMediator:onRemove()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    self:getViewComponent():removeFromParent()
    gameFacade:removeMediator("WaitingRiseMediator")
end

function WaitingRiseMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	if name == GameConstants.UPDATE_WAITINGRISE then
    print("comehere656")
       local waitRise=gameFacade:retrieveProxy("WaitingRiseProxy")
       local respMsg=waitRise:getData().respMsg
       self.rank:setString(respMsg.iRanking.."")
       self.deskNum:setString(respMsg.iTablePlaying.."")
       self:addRoundItem()
    end
end
function WaitingRiseMediator:addRoundItem()
    local tRounds=self:getRounds()
    local players=tRounds.players
    local round=tRounds.round
    for i=1,round do 
        local item=self.roundTempl:clone()
        local indexs=i
        local textColor=cc.c4b(168,66,0)
        if indexs~=1 then
           indexs=indexs%2+2
           if indexs==2 then textColor=cc.c3b(72,106,0)
           else
           textColor=cc.c3b(00,89,130)
           end
        end
        
        local path=string.format("game/res/ui_res/waitrise/jinji%s.png", indexs)
        item:loadTexture(path)
        local roundNumText=seekNodeByName(item,"roundNum")
        local riseNumText=seekNodeByName(item,"riseNum")
        dump(textColor,"textColor",10)
        roundNumText:setTextColor(textColor)
        dump(textColor,"textColor2",10)
        roundNumText:setString(i.."")
        local str=players.."进"..(players/2)
        riseNumText:setString(str)
        players=players/2
        item:setVisible(true)
        if i==1 then
--           roundNumText:setPositionX(roundNumText:getPositionX()-4)
           riseNumText:setPositionX(riseNumText:getPositionX()-21)
        end
        item:setPosition(500+135*(i-1),365)
        self:getViewComponent():addChild(item)
    end
end
function WaitingRiseMediator:getRounds()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local PlatformConstants = cc.exports.PlatformConstants
    local waitRise=gameFacade:retrieveProxy("WaitingRiseProxy")
    local gameRoom=gameFacade:retrieveProxy("GameRoomProxy")
    local cptMoreGame=platformFacade:retrieveProxy("CptMoreGameProxy")
    local gameId=gameRoom:getData().gameId
    local gameList=cptMoreGame:getData().gameList
    local playerPerDesk=0
    local players=waitRise:getData().respMsg.iBeginPlayers
    local len=#gameList
    local i=1
    while i<=len do
        if gameList[i].gameId==gameId then 
           playerPerDesk=gameList[i].playerPerDesk
           i=len
        end
        i=i+1
    end
    local temp=players
    local round=-1
    while temp>=playerPerDesk do
          temp=temp/2
          round=round+1
    end
    return {round=round,players=players}
end

return WaitingRiseMediator