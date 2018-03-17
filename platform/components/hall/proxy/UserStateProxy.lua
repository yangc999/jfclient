--Date 2018.2.8
--记录玩家是否在房间类

local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local UserStateProxy = class("UserStateProxy", Proxy)

function UserStateProxy:ctor()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
	UserStateProxy.super.ctor(self, "UserStateProxy")
    local data = ProxyData.new()  --公告所用的数据部分
    data:prop("stateType", 0)  --用户当前状态  0 在大厅没进入房间，1 在好友房，2 在配备房
    data:prop("roomID", nil)   --房间ID
    self:setData(data)
end

function UserStateProxy:onRegister()
    -- local tarslib = cc.load("jfutils").Tars
    -- local path = cc.FileUtils:getInstance():fullPathForFilename("platform/components/shop/tars/PayHttpProto.tars")
    -- tarslib.register(path)
end

function UserStateProxy:onRemove()
end

return UserStateProxy

--endregion
