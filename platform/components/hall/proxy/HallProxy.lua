
local Proxy = cc.load("puremvc").Proxy
local ProxyData = cc.load("jfutils").ProxyData
local HallProxy = class("HallProxy", Proxy)

function HallProxy:ctor()
	HallProxy.super.ctor(self, "HallProxy")
    local data = ProxyData.new()
    local networkType = cc.exports.getNetworkType()
    data:prop("bgMusicID", nil)         --背景音乐id
    data:prop("effectMusicCanPlay", 1)  --按钮音效是否能播放 1能播放，0不能播放
    data:prop("bgMusicCanPlay",1)       --背景音效是否能播放 1能播放，0不能播放
    data:prop("netstate", networkType)  --当前网络是WIFI还是4G
    self:setData(data)
end

function HallProxy:onRegister()
end

function HallProxy:onRemove()
end

return HallProxy