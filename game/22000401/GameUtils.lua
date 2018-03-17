
local GameUtils = class("GameUtils")

local selfChair = 0
local NTChair = 0

function GameUtils:getInstance()
    if not self.GameUtils then
        self.GameUtils = self.new()
    end
    return self.GameUtils
end

function GameUtils:onDestroy()
    if self and self.GameUtils then
        selfChair = 0
        NTChair = 0
        self.GameUtils = nil
    end
end

-- 发送网络消息  assId 消息id  pak1 消息数据    structName 对应的tars下的struct  
function GameUtils:sendNotification(assId,pak1,structName)
    print("-------------------------------> GameUtils:sendNotification start")
    print("assId = " .. tostring(assId))
    dump(pak1,"data")

    if structName == nil then
        print("error!")
        return
    end

    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local tarslib = cc.load("jfutils").Tars
    local req1 = tarslib.encode(pak1,structName)
    local pak2 = {
        nVer = 1001,
        nCmd = assId,
        vecMsgData = req1
    }
    local req2 = tarslib.encode(pak2, "JFGameSoProto::TSoMsg")
	gameFacade:sendNotification(GameConstants.SEND_SOCKET, req2, 1)
    print("-------------------------------> GameUtils:sendNotification end")
end

-- 根据服务器的椅子chair  获取UI上的椅子位置
function GameUtils:getUIChairByServerChair(chair)
    print("selfChair = " .. tostring(selfChair))
    if MyGameConstants.PLAYER_COUNT == 2 then
        if selfChair == chair then
            return 1
        else
            return 3
        end
    elseif MyGameConstants.PLAYER_COUNT == 3 then
        if selfChair == chair then
            return 1
        elseif (selfChair + 1) % MyGameConstants.PLAYER_COUNT == chair then
            return 2
        else
            return 4
        end
    end
    return (4 + tonumber(chair) - selfChair)%4+1
end

--UI椅子位置 获取对应的serverchair
function GameUtils:getServerChairByUIChair(uiChair)
    local chair = -1
    for i = 0,MyGameConstants.PLAYER_COUNT-1  do
        if uiChair == getUIChairIndexByServerChair(i) then
            chair = i
            break
        end
    end
    return chair
end

--获取自己的椅子号
function GameUtils:getSelfServerChair()
    return selfChair
end

--设置自己的椅子号
function GameUtils:setSelfServerChair( chair )
    selfChair = chair
end
 
--获取庄家的椅子号
function GameUtils:getNTServerChair()
    return NTChair
end

--设置庄家的椅子号
function GameUtils:setNTServerChair( chair )
    NTChair = chair
end

-- 得到当前游戏类型 1-房卡场 2-自由选桌(金币场) 3-快速开始(金币场) 4-比赛场 10-录像
function GameUtils:getGameType()
    local gameType = 1
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    if gameFacade:hasProxy("GameRoomProxy") then
        local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")
        gameType = gameRoom:getData().gameType
    end
    return gameType
end

-- 获取游戏房号
function GameUtils:getGameRoomKey()
    local roomKey = nil
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    if GameUtils:getInstance():getGameType() == 1 or GameUtils:getInstance():getGameType() == 10 then
        if gameFacade:hasProxy("GameRoomProxy") then
            roomKey = gameFacade:retrieveProxy("GameRoomProxy"):getData().roomKey
        end
    end
    return roomKey
end

----------------------------UserDefault-------------------------------
-- 设置麻将桌布
function GameUtils:setMJTableCloth(item)
    cc.UserDefault:getInstance():setIntegerForKey( "mjtableclothtype" , item )
end

function GameUtils:getMJTableCloth()
    local tablecloth = cc.UserDefault:getInstance():getIntegerForKey( "mjtableclothtype") 
    if tablecloth <= 0 then
        return 1
    else
        return tablecloth
    end
end

-- 设置麻将牌背
function GameUtils:setMJCardBack(item)
    cc.UserDefault:getInstance():setIntegerForKey( "mjcardbacktype" , item )
end

function GameUtils:getMJCardBack()
    local cardcolor = cc.UserDefault:getInstance():getIntegerForKey( "mjcardbacktype")
    if cardcolor <= 0 then
        return 1
    else
        return cardcolor
    end
end

-- 设置麻将语言类型 (0- 普通话 1- 方言)
function GameUtils:setMJLanguageType(item)
    cc.UserDefault:getInstance():setIntegerForKey( "mjlanguagetype" , item )
end

function GameUtils:getMJLanguageType()
    return cc.UserDefault:getInstance():getIntegerForKey( "mjlanguagetype")
end

-- 设置麻将背景音乐音量
function GameUtils:setMJMusicValue(value)
    cc.UserDefault:getInstance():setIntegerForKey( "mjmusicvalue" , value )
    AudioEngine.setMusicVolume(value / 100)
end

function GameUtils:getMJMusicValue()
    return cc.UserDefault:getInstance():getIntegerForKey("mjmusicvalue",50)
end

-- 设置麻将音效音量
function GameUtils:setMJEffectValue(value)
    cc.UserDefault:getInstance():setIntegerForKey( "mjeffectvalue" , value )
    AudioEngine.setEffectsVolume(value / 100)
end

function GameUtils:getMJEffectValue()
    return cc.UserDefault:getInstance():getIntegerForKey("mjeffectvalue",50)
end

return GameUtils
