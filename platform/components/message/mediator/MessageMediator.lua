
local Mediator = cc.load("puremvc").Mediator
local MessageMediator = class("MessageMediator", Mediator)

function MessageMediator:ctor(scene)
	MessageMediator.super.ctor(self, "MessageMediator")
	self.scene = scene
end

function MessageMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.UPDATE_MESSAGE,
	}
end

function MessageMediator:onRegister()
	--[[
	local text = ccui.Text:create("", "", 36)
	text:setAnchorPoint(cc.p(0.5, 0.5))
	text:setPosition(display.cx, display.cy)
	text:setVisible(false)
	text:setLocalZOrder(1000)
	self:setViewComponent(text)
	--]]
	local ui = cc.CSLoader:createNode("hall_res/messageTip/message.csb")  --设置UI的csb
	self:setViewComponent(ui)
	self:getViewComponent():setZOrder(1000)

    self:getViewComponent():setVisible(false)
	self.scene:addChild(self:getViewComponent())

	self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--背景
	self.tipmessage = seekNodeByName(self.bgImg,"text_message")

end

function MessageMediator:onRemove()
	self:getViewComponent():removeFromParent(true)
	self:setViewComponent(nil)
end

function MessageMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.UPDATE_MESSAGE then
		print("setMessage", body)
		self:getViewComponent():stopAllActions()
		self:getViewComponent():setVisible(true)
		--self:getViewComponent():setString(body)
		self.tipmessage:setString(body)

		self:getViewComponent():runAction(cc.Sequence:create(
			cc.DelayTime:create(2), 
			cc.CallFunc:create(function()
				self:getViewComponent():setVisible(false)
			end)))
	end
end

return MessageMediator