--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local MatchRecordsData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local MatchRecordsProxy = class("MatchRecordsProxy", Proxy)

function MatchRecordsProxy:ctor()
    print("MatchRecordsProxy:ctor")
	MatchRecordsProxy.super.ctor(self, "MatchRecordsProxy")

    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    local data = MatchRecordsData.new()  --公告所用的数据部分
	
    data:prop("nRecordNum", 0) --纪录总数
    data:prop("vRecordList", {})  --自己的战绩列表
    data:prop("vCurRoundList", {})  --当前战局列表
    data:prop("vIndexList",  {})   --当前请求的纪录索引列表
    data:prop("vCurRecordDetail", {}) --当前请求的战绩详情
    data:prop("bScrollListTop", false) --战绩列表是否滚到最顶
    data:prop("bScrollListBottom", false) --战绩列表是否滚到最尾
    data:prop("nMinIndex", -1)   --请求的最小战绩index
    data:prop("nMaxIndex", -1)  --请求最大序号的战绩的index
    data:prop("curIndex", 1)  --当前选择的战绩index
    data:prop("sVideoPath",nil) --返回录像地址
    data:prop("sRoomNo",nil) --roomNo房间ID
    data:prop("watchVideo",nil) --录像回放资源

	self:setData(data)
	
end

function MatchRecordsProxy:onRegister()
    print("MatchRecordsProxy:onRegister")

    local tarslib = cc.load("jfutils").Tars
	local path1 = cc.FileUtils:getInstance():fullPathForFilename("platform/components/matchrecords/tars/StandingsHttpProto.tars")
    
	tarslib.register(path1)
    print("end MatchRecordsProxy:onRegister")
end

function MatchRecordsProxy:onRemove()
end

return MatchRecordsProxy


--endregion
