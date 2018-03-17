
local Mediator = cc.load("puremvc").Mediator
local VoteMediator = class("VoteMediator", Mediator)

function VoteMediator:ctor()
	VoteMediator.super.ctor(self, "VoteMediator")
end

function VoteMediator:listNotificationInterests()
	local GameConstants = cc.exports.GameConstants
	return {
		GameConstants.END_VOTE, 
		GameConstants.UPDATE_VOTE, 
	}
end

function VoteMediator:onRegister()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    cc.FileUtils:getInstance():addSearchPath("game/res")
	
	local node = cc.CSLoader:createNode("game/res/ui_csb/vote.csb")
    local bg = node:getChildByName("Img_bg")
	local agree = bg:getChildByName("Btn_agree")
	local refuse = bg:getChildByName("Btn_refuse")
	agree:addClickEventListener(function()
		gameFacade:sendNotification(GameConstants.REQUEST_VOTE, true)
	end)	
	refuse:addClickEventListener(function()
		gameFacade:sendNotification(GameConstants.REQUEST_VOTE, false)
	end)
	self.agree = agree
	self.refuse = refuse
    self.dismisman = bg:getChildByName("Text_2")
    self.votemen = bg:getChildByName("Txt_2")

	self:setViewComponent(node)
	
	local scene = gameFacade:retrieveMediator("SceneMediator").scene
	scene:addChild(node)
end

function VoteMediator:onRemove()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	gameFacade:removeProxy("VoteProxy")
	self:getViewComponent():removeFromParent(true)
end

function VoteMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	if name == GameConstants.END_VOTE then
		print("end vote")
		gameFacade:removeMediator("VoteMediator")
	elseif name == GameConstants.UPDATE_VOTE then
		local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
		local login = platformFacade:retrieveProxy("LoginProxy")
		local disstr = ""
        local votestr = ""
        local result = ""
		local desk = gameFacade:retrieveProxy("DeskProxy")
		local vote = gameFacade:retrieveProxy("VoteProxy")
		for _,v in pairs(desk:getData().player) do
            result = vote:getResult(v.uid)
            if v.uid == vote:getVoteman() then
                disstr = string.format("玩家【%s】申请解散房间，请等待其他玩家\n\n选择(超过%d分钟未做选择，则默认接受)",v.name, 5)
                self.dismisman:setString(disstr)
            else
			    votestr = votestr .. string.format("【%s】     %s\n\n", v.name, result)
            end   


			if v.uid == login:getData().uid then
				self.agree:setVisible(string.len(result) == string.len("等待选择"))
				self.refuse:setVisible(string.len(result) == string.len("等待选择"))
			end
		end

        print("indicate str:", votestr)
        self.votemen:setString(votestr)
--		self.text:setString(str)
	end
end

return VoteMediator