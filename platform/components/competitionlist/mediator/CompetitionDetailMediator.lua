local CompetitionDetailMediator=class("CompetitionDetailMediator",cc.load("puremvc").Mediator)
local CptListDetailProxy = import("..proxy.CptListDetailProxy")

local  RichTextEx=import("......src.packages.jfutils.RichTextEx")


function CompetitionDetailMediator:ctor()
	CompetitionDetailMediator.super.ctor(self, "CompetitionDetailMediator")
end	

function CompetitionDetailMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
    PlatformConstants.UPDATE_SHOWCOMPETITIONDETAIL,
	}
end

function CompetitionDetailMediator:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants

--    platformFacade:registerProxy(CptListDetailProxy.new())

	local competitionList = platformFacade:retrieveProxy("CompetitionListProxy")
	local scene = platformFacade:retrieveMediator("HallMediator").scene
	local ui = cc.CSLoader:createNode("hall_res/competitionList/CompetitionDetailLayer.csb")
	self:setViewComponent(ui)
	scene:addChild(ui)
    self.list=seekNodeByName(ui,"list_content")
    self.list:setScrollBarEnabled(false)


    local  btnRule=seekNodeByName(ui,"btn_rule")
    local  btnReward=seekNodeByName(ui,"btn_reward")
    local  btnClose=seekNodeByName(ui,"btn_close")
    btnReward:setTouchEnabled(false)
    btnReward:setSelected(true)
    self:showReward()
    btnClose:addClickEventListener(function ()
       platformFacade:removeMediator("CompetitionDetailMediator")
end)
    btnRule:addClickEventListener(function ()
       btnRule:setTouchEnabled(false)
       btnReward:setTouchEnabled(true)
       btnReward:setSelected(false)
       self:showRule()   
end)
    btnReward:addClickEventListener(function ()
       btnRule:setTouchEnabled(true)
       btnReward:setTouchEnabled(false)
       btnRule:setSelected(false)
       self:showReward()
end)


end 

function CompetitionDetailMediator:onRemove()
	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:removeProxy("CptListDetailProxy")
	platformFacade:removeCommand(PlatformConstants.REQUEST_COMPETITIONLIST)
    platformFacade:removeCommand(PlatformConstants.START_MATCHSHARE)
    
end

function CompetitionDetailMediator:showReward()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local cptDetail=platformFacade:retrieveProxy("CptListDetailProxy")
    local matchAwardListPresent=cptDetail:getData().matchAwardListPresent

    local color = cc.c3b(255,255,255)
    local textFont = "font/fangzhenyuanstatic.ttf"
    local textSize =24
    local rowSpace = 60 --行间距
    self.list:removeAllChildren()

    dump(matchAwardListPresent,"matchAwardListPresent",10)
    local len=#matchAwardListPresent
    self.list:setInnerContainerSize(cc.size(self.list:getInnerContainerSize().width,len*rowSpace))
    for i=1,len do 
        local gainType=""
        local rankText=""
        local rankText2=""
        local richText = ccui.RichText:create()
        richText:ignoreContentAdaptWithSize(true)
        richText:setAnchorPoint(cc.p(0.0,1.0))
        local richText2 = ccui.RichText:create()
        richText2:ignoreContentAdaptWithSize(true)
        richText2:setAnchorPoint(cc.p(0.0,1.0))
        if matchAwardListPresent[i].gainType==1 then     gainType="元话费"
           elseif matchAwardListPresent[i].gainType==2 then gainType="钻石"
           elseif matchAwardListPresent[i].gainType==3 then gainType="张房卡"
           elseif matchAwardListPresent[i].gainType==4 then gainType="金币"
        end
        if matchAwardListPresent[i].num==1 then
           rankText="第"..matchAwardListPresent[i].start.."名"
           rankText2=matchAwardListPresent[i].gainValue..gainType
        else
           rankText="第"..matchAwardListPresent[i].start.."名".."～第"..matchAwardListPresent[i].start+(matchAwardListPresent[i].num-1).."名"
           rankText2=matchAwardListPresent[i].gainValue..gainType
        end
        local element = ccui.RichElementText:create(1, color, 255, rankText, textFont, textSize)
        richText:pushBackElement(element)
        richText:setPosition(50,  self.list:getInnerContainerSize().height-(i-1) * rowSpace - 50)
        richText:formatText()
        self.list:addChild(richText)

        local element2 = ccui.RichElementText:create(1, color, 255, rankText2, textFont, textSize)
        richText2:pushBackElement(element2)
        richText2:setPosition(364,  self.list:getInnerContainerSize().height-(i-1) * rowSpace - 50)
        richText2:formatText()
        self.list:addChild(richText2)
    end
    self.list:scrollToTop(0.1,false)
end

function CompetitionDetailMediator:showRule()
  self.list:removeAllChildren()

  local ruleText={"比赛规则","1.所有玩家加入比赛后初始化积分均为固定值。","2.比赛赛制位淘汰赛制,32进16,16进8,8进4,最后4","人定名次,共3轮,每轮3局","3.每轮全部玩家完成比赛后,被淘汰者按照淘汰时","的积分进行排名。","参赛规则：报名人数满32人开始一场比赛。每次","报名消耗25张房卡。","",}
  local len=#ruleText
  local color = cc.c3b(255,255,255)
  local textFont = "font/fangzhenyuanstatic.ttf"
  local textSize =20
  local rowSpace = 40 --行间距
  local offsety=50
  self.list:setInnerContainerSize(cc.size(self.list:getInnerContainerSize().width,len*rowSpace))
  for i=1,len do
  rowSpace = 40
  textSize=24
  offsety=50
  local richText = ccui.RichText:create()
        richText:ignoreContentAdaptWithSize(true)
        richText:setAnchorPoint(cc.p(0.0,1.0))
        if i==1 then 
        textSize=40
        offsety=20
        end
  local element = ccui.RichElementText:create(2, color, 255, ruleText[i], textFont, textSize)
  richText:pushBackElement(element)
  richText:setPosition(25,  self.list:getInnerContainerSize().height-(i-1) * rowSpace - offsety)
  richText:formatText()
  self.list:addChild(richText)
  self.list:scrollToTop(0,false)
  end
        
end

function CompetitionDetailMediator:handleNotification(notification)

end
return CompetitionDetailMediator
