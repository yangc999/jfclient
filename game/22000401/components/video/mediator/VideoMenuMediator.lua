
local Mediator = cc.load("puremvc").Mediator
local VideoMenuMediator = class("VideoMenuMediator", Mediator)

function VideoMenuMediator:ctor(root)
    print("-------------->VideoMenuMediator:ctor")
	VideoMenuMediator.super.ctor(self, "VideoMenuMediator")
    self.root = root
end

function VideoMenuMediator:listNotificationInterests()
    print("-------------->VideoMenuMediator:listNotificationInterests")
    local GameConstants = cc.exports.GameConstants
	return
    {
        "video_updateframe",
        GameConstants.EXIT_GAME,
    }
end

function VideoMenuMediator:onRegister()
    print("-------------->VideoMenuMediator:onRegister")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    self.isPause = false

    -- 快进
    local Button_advance = self.root:getChildByName("Button_advance")
    Button_advance:addClickEventListener(function()
        gameFacade:sendNotification(MyGameConstants.C_ADVANCE)
    end)

	-- 快退
    local Button_backward = self.root:getChildByName("Button_backward")
    Button_backward:addClickEventListener(function()
        gameFacade:sendNotification(MyGameConstants.C_BACKWARD)
    end)

    -- 暂停
    local Button_pause = self.root:getChildByName("Button_pause")
    self.Button_pause = Button_pause
    Button_pause:addClickEventListener(function()
        self:pauseCallBack()
    end)

    -- 重新播放
    local Button_return = self.root:getChildByName("Button_return")
    Button_return:addClickEventListener(function()
        self:returnCallBack()
    end)

    -- 返回
    local Button_back = self.root:getChildByName("Button_back")
    Button_back:addClickEventListener(function()
        gameFacade:sendNotification(GameConstants.EXIT_GAME)
    end)

    -- 帧数
    self.Text_frame = self.root:getChildByName("Text_frame")
end

function VideoMenuMediator:onRemove()
    print("-------------->VideoMenuMediator:onRemove")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	self:setViewComponent(nil)
end

function VideoMenuMediator:handleNotification(notification)
    print("-------------->VideoMenuMediator:handleNotification")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	
    if name == GameConstants.EXIT_GAME then
        gameFacade:removeMediator("VideoMenuMediator")
    elseif name == "video_updateframe" then
        self:updateFrame()
    end
end
------------------------------------------------------------------------------------
-- 暂停
function VideoMenuMediator:pauseCallBack()
    print("VideoMenuMediator:pauseCallBack")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("VideoProxy"):getData()
    if data.IsPause == true then
        self.Button_pause:loadTextures("ui_res/video/pause.png","","")
        self.Button_pause:setContentSize(48,45)
        data.IsPause = false

        local root = gameFacade:retrieveMediator("VideoMediator").root
        performWithDelay(root,function()
            gameFacade:sendNotification(MyGameConstants.C_PLAY_VIDEO)
        end,1)
    else
        self.Button_pause:loadTextures("ui_res/video/continue.png","","")
        self.Button_pause:setContentSize(41,49)
        data.IsPause = true

        local root = gameFacade:retrieveMediator("VideoMediator").root
        root:stopAllActions()
    end
end

-- 重新播放
function VideoMenuMediator:returnCallBack()
    print("VideoMenuMediator:returnCallBack")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("VideoProxy"):getData()
    local root = gameFacade:retrieveMediator("VideoMediator").root
    root:stopAllActions()

    gameFacade:sendNotification(MyGameConstants.C_CLOSE_RESULT)
    gameFacade:sendNotification(MyGameConstants.C_GAME_INIT)

    data.CurIndex = 0
    gameFacade:sendNotification(MyGameConstants.C_PLAY_VIDEO)
end

-- 刷新帧数
function VideoMenuMediator:updateFrame()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("VideoProxy"):getData()
    local index = data.CurIndex
    local allIndex = data.AllIndex
    self.Text_frame:setString(index .. "/" .. allIndex)
end


return VideoMenuMediator