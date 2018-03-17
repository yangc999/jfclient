
local Proxy = cc.load("puremvc").Proxy
local LocationProxy = class("LocationProxy", Proxy)

function LocationProxy:ctor()
	LocationProxy.super.ctor(self, "LocationProxy")
end

function LocationProxy:onRegister()
end

function LocationProxy:onRemove()
end

return LocationProxy