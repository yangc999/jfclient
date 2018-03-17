
local Proxy = cc.load("puremvc").Proxy
local VoiceProxy = class("VoiceProxy", Proxy)

function VoiceProxy:ctor()
	VoiceProxy.super.ctor(self, "VoiceProxy")
end

function VoiceProxy:onRegister()
end

function VoiceProxy:onRemove()
end

return VoiceProxy