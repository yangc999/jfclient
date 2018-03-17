
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local PlayerInfoProxy = class("PlayerInfoProxy", Proxy)

function PlayerInfoProxy:ctor()
    print("------------>PlayerInfoProxy:ctor")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local gameConstants = cc.exports.GameConstants

	PlayerInfoProxy.super.ctor(self, "PlayerInfoProxy")
	local data = ProxyData.new()

    data:prop("CurPlayerNums",0)
    data:prop("IsAuto",false)
    data:prop("IsPrepare",false)
    data:prop("BFreUserleave",false)
    data:prop("AgreeGameUser", 0,gameFacade, "PL_agreegame")
    data:prop("AutoData", {},gameFacade, "PL_auto")
	data:prop("MakeNTData", {},gameFacade, "PL_makent")
    data:prop("ScoreData", {0,0,0,0},gameFacade, "PL_updatescore")
    data:prop("PiaoData", {},gameFacade, "PL_piao")
    data:prop("CurSitPlayer", {},gameFacade, "PL_cursitplayer")
    data:prop("CurStandPlayer", {},gameFacade, "PL_curstandplayer")
    data:prop("CurOfflinePlayer", {},gameFacade, "PL_curofflineplayer")
    data:prop("CurRecomePlayer", {},gameFacade, "PL_currecomeplayer")
    data:prop("AllUserInfo", {},gameFacade, "PL_alluserinfo")
    data:prop("GameStationData", {},gameFacade, "PL_gamestation")

	self:setData(data)
end

function PlayerInfoProxy:onRegister()
    print("------------>PlayerInfoProxy:onRegister")

end

function PlayerInfoProxy:onRemove()
    print("------------>PlayerInfoProxy:onRemove")
end

return PlayerInfoProxy
