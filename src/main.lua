
cc.FileUtils:getInstance():setPopupNotify(false)

--avoid disable global
-----------------------------------------------------
require "socket"
require "mime"
require "ltn12"
require "socket.ftp"
require "socket.headers"
require "socket.http"
require "socket.mbox"
require "socket.smtp"
require "socket.tp"
require "socket.url"
-----------------------------------------------------

require "config"
require "cocos.init"

cc.Director:getInstance():setAnimationInterval(1.0/30.0)

require "platform.init"
require "game.init"

print = release_print

local function main()
    --require("app.MyApp"):create():run()
    local scene = cc.Scene:create()
    cc.Director:getInstance():runWithScene(scene)
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    platformFacade:sendNotification(PlatformConstants.START_MESSAGE, scene)
    platformFacade:sendNotification(PlatformConstants.START_LOAD, scene)
	platformFacade:sendNotification(PlatformConstants.CREATE_LOADINGANIM, scene)  --创建Loading动画
    local msgData = {scene = scene, msg = msg}
    platformFacade:sendNotification(PlatformConstants.CREATE_MSGBOX, msgData)
    --platformFacade:sendNotification(PlatformConstants.TEST_NETWORK)

	local keyboardEventListener = cc.EventListenerKeyboard:create()
    keyboardEventListener:registerScriptHandler(function(keyCode, event)
        print("keyCode", keyCode)
        if keyCode == cc.KeyCode.KEY_BACK then
            if platformFacade:retrieveMediator("JoinRoomMediator") then
                platformFacade:removeMediator("JoinRoomMediator")
            elseif platformFacade:retrieveMediator("CreateRoomMediator") then
                platformFacade:removeMediator("CreateRoomMediator")
            elseif platformFacade:retrieveMediator("ShopMediator") then
                platformFacade:removeMediator("ShopMediator")
            elseif platformFacade:retrieveMediator("BankMediator") then
                platformFacade:removeMediator("BankMediator")
            elseif platformFacade:retrieveMediator("AnnounceListMediator") then
                platformFacade:removeMediator("AnnounceListMediator")
            elseif platformFacade:retrieveMediator("LotteryMediator") then
                platformFacade:removeMediator("LotteryMediator")
            elseif platformFacade:retrieveMediator("UserInfoMediator") then
                platformFacade:removeMediator("UserInfoMediator")
            elseif platformFacade:retrieveMediator("PrivateRoomMediator") then
                platformFacade:removeMediator("PrivateRoomMediator")
            elseif platformFacade:retrieveMediator("HallMediator") then
                platformFacade:sendNotification(PlatformConstants.REQUEST_LOGOUT)
           	elseif platformFacade:retrieveMediator("LoginMediator") then
           		cc.Director:getInstance():endToLua()
            end
        end
    end, cc.Handler.EVENT_KEYBOARD_PRESSED)
    local eventDispatcher = scene:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(keyboardEventListener, scene)
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
