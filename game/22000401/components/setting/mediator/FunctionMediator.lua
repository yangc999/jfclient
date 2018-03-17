local Mediator = cc.load("puremvc").Mediator
local FunctionMediator = class("FunctionMediator", Mediator)
local GameMusic = import("....GameMusic")

function FunctionMediator:ctor(root)
    print("-------------->FunctionMediator:ctor")
	FunctionMediator.super.ctor(self, "FunctionMediator",root)
    self.root = root
end

function FunctionMediator:listNotificationInterests()
    print("-------------->FunctionMediator:listNotificationInterests")
	return
    {
        GameConstants.EXIT_GAME,
    }
end

function FunctionMediator:onRegister()
    print("-------------->FunctionMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    local image_root = gameFacade:retrieveMediator("MainMediator").image_root

    -- 音效
    local Button_effect = self.root:getChildByName("Button_effect")
    self.Button_effect = Button_effect
    Button_effect:addClickEventListener(function()
        self:effectCallBack()
    end)

    -- 音乐
    local Button_music = self.root:getChildByName("Button_music")
    self.Button_music = Button_music
    Button_music:addClickEventListener(function()
        self:musicCallBack()
    end)

    -- 音效滑件
    local Slider_effect = self.root:getChildByName("Slider_effect")
    self.Slider_effect = Slider_effect
    Slider_effect:addEventListener(function(sender,eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local slider = sender
            local percent = slider:getPercent()
            print("effectPercent = " .. percent)
            GameUtils:getInstance():setMJEffectValue(percent)
            if percent == 0 then
                self.Button_effect:loadTextures("ui_res/Setting/music_dis.png","","")
            else
                self.Button_effect:loadTextures("ui_res/Setting/music_normal.png","","")
            end
        end
    end)

    -- 音乐滑件
    local Slider_mucic = self.root:getChildByName("Slider_mucic")
    self.Slider_mucic = Slider_mucic
    Slider_mucic:addEventListener(function(sender,eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local slider = sender
            local percent = slider:getPercent()
            print("musicPercent = " .. percent)
            GameUtils:getInstance():setMJMusicValue(percent)
            if percent == 0 then
                self.Button_music:loadTextures("ui_res/Setting/music_dis.png","","")
            else
                self.Button_music:loadTextures("ui_res/Setting/music_normal.png","","")
            end
        end
    end)
   
   self:updateSlider()
end

function FunctionMediator:onRemove()
    print("-------------->FunctionMediator:onRemove")
	self:setViewComponent(nil)
end

function FunctionMediator:handleNotification(notification)
    print("-------------->FunctionMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	
    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("FunctionMediator")
    end
end

---------------------------------------------------------------------------
function FunctionMediator:updateSlider()
    local musicVuale = GameUtils:getInstance():getMJMusicValue()
    if musicVuale == 0 then
        self.Slider_mucic:setPercent(musicVuale)
        self.Button_music:loadTextures("ui_res/Setting/music_dis.png","","")
    elseif musicVuale > 0 then
        self.Slider_mucic:setPercent(musicVuale)
        self.Button_music:loadTextures("ui_res/Setting/music_normal.png","","")
    end

    local effectVuale = GameUtils:getInstance():getMJEffectValue()
    if effectVuale == 0 then
        self.Slider_effect:setPercent(effectVuale)
        self.Button_effect:loadTextures("ui_res/Setting/effect_dis.png","","")
    elseif effectVuale > 0 then
        self.Slider_effect:setPercent(effectVuale)
        self.Button_effect:loadTextures("ui_res/Setting/effect_normal.png","","")
    end
end

function FunctionMediator:effectCallBack()
    GameMusic:playClickEffect()
    local vuale = GameUtils:getInstance():getMJEffectValue()
    if vuale > 0 then
        self.Slider_effect:setPercent(0)
        self.Button_effect:loadTextures("ui_res/Setting/effect_dis.png","","")
        GameUtils:getInstance():setMJEffectValue(0)
    elseif vuale == 0 then  
        self.Slider_effect:setPercent(100)
        self.Button_effect:loadTextures("ui_res/Setting/effect_normal.png","","")
        GameUtils:getInstance():setMJEffectValue(100)
    end
end

function FunctionMediator:musicCallBack()
     GameMusic:playClickEffect()
    local vuale = GameUtils:getInstance():getMJMusicValue()
    if vuale > 0 then
        self.Slider_mucic:setPercent(0)
        self.Button_music:loadTextures("ui_res/Setting/music_dis.png","","")
        GameUtils:getInstance():setMJMusicValue(0)
    elseif vuale == 0 then 
        self.Slider_mucic:setPercent(100)
        self.Button_music:loadTextures("ui_res/Setting/music_normal.png","","")
        GameUtils:getInstance():setMJMusicValue(100)
    end
end

return FunctionMediator