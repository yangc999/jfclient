
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local VideoProxy = class("VideoProxy", Proxy)

function VideoProxy:ctor()
    print("------------>VideoProxy:ctor")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local gameConstants = cc.exports.GameConstants

	VideoProxy.super.ctor(self, "VideoProxy")
	local data = ProxyData.new() 
    data:prop("ActNotifyData", {},gameFacade, "video_actnotify")
    data:prop("ActInfoData", {},gameFacade, "video_actinfo")
    data:prop("CurIndex",0,gameFacade,"video_updateframe")  -- 当前帧数
    data:prop("AllIndex",0)      -- 总帧数
    data:prop("IsPause",false)
    data:prop("GameMsgData",{})   -- 游戏消息数据
    data:prop("GameStateData",{}) -- 每帧断线重连数据

	self:setData(data)
end

function VideoProxy:onRegister()
    print("------------>VideoProxy:onRegister")
end

function VideoProxy:onRemove()
    print("------------>VideoProxy:onRemove")
end

return VideoProxy
