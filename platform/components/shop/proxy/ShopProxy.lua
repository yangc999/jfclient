--region *.lua
--Date 2017.11.02
--商城代理类

local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local ShopProxy = class("ShopProxy", Proxy)

function ShopProxy:ctor()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants

	ShopProxy.super.ctor(self, "ShopProxy")

    local data = ProxyData.new()  --公告所用的数据部分
    data:prop("coinlist", {}, platformFacade, PlatformConstants.UPDATE_SHOPCOINLIST)  --金币商品列表
    data:prop("diamondlist", {}, platformFacade, PlatformConstants.UPDATE_SHOPDIAMONDLIST)  --钻石商品列表
    data:prop("fangkalist", {}, platformFacade, PlatformConstants.UPDATE_SHOPFANGKALIST)  --房卡商品列表
    data:prop("reqType", 1)  --当前请求购买的商品种类 2.钻石 3.房卡 4.金币
    data:prop("curlist", {}) --当前的商品列表
    data:prop("curOrder", nil)  --当前商品的订单号
    data:prop("loop", nil)
    self:setData(data)
end

function ShopProxy:onRegister()
    local tarslib = cc.load("jfutils").Tars
    local path = cc.FileUtils:getInstance():fullPathForFilename("platform/components/shop/tars/PayHttpProto.tars")
    tarslib.register(path)
end

function ShopProxy:onRemove()
end

return ShopProxy

--endregion
