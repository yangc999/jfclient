--region *.lua
--Date 2017.11.02
--抽奖代理类

local LotteryData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local LotteryProxy = class("LotteryProxy", Proxy)

function LotteryProxy:ctor()
    print("LotteryProxy:ctor")
	LotteryProxy.super.ctor(self, "LotteryProxy")

    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    local data = LotteryData.new()  --公告所用的数据部分
	--data:prop("anlist", {}, platformFacade, PlatformConstants.SHOW_LotteryLIST)  --公告列表，公告数据改变时，发送SHOW_LotteryLIST消息
    data:prop("curType", 1)  --当前抽奖的类型 1：免费抽奖  2：幸运转转乐抽奖
    data:prop("freeGiftList", {}, platformFacade, PlatformConstants.UPDATE_LOTTERYFREELIST)      --免费抽奖的奖品列表
    data:prop("vipGiftList", {}, platformFacade, PlatformConstants.UPDATE_LOTTERYVIPLIST)        --幸运转转乐的奖品列表
    data:prop("freeTimes", 0, platformFacade, PlatformConstants.UPDATE_FREETIMES)  --免费抽奖次数
    data:prop("payTimes", 0, platformFacade, PlatformConstants.UPDATE_PAYTIMES)  --付费抽奖次数
    data:prop("rollerResult", nil)  --获得抽奖结果
    data:prop("vlogList", {})  --自己的获奖列表
    data:prop("vTotalList", {})  --全部的获奖列表
    data:prop("curAwardIdx", -1)  --当前抽奖中的物品下标
	self:setData(data)
	
end

function LotteryProxy:onRegister()
    print("LotteryProxy:onRegister")

    local tarslib = cc.load("jfutils").Tars
	local path1 = cc.FileUtils:getInstance():fullPathForFilename("platform/components/lottery/tars/ActivitysHttpProto.tars")
    
	tarslib.register(path1)
    print("end LotteryProxy:onRegister")
end

function LotteryProxy:onRemove()
end

return LotteryProxy

--endregion
