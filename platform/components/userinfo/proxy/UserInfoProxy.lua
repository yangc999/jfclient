
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local UserInfoProxy = class("UserInfoProxy", Proxy)

function UserInfoProxy:ctor()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	UserInfoProxy.super.ctor(self, "UserInfoProxy")
	local data = ProxyData.new()
	data:prop("userName", nil, platformFacade, PlatformConstants.UPDATE_USERNAME)
	data:prop("nickName", nil, platformFacade, PlatformConstants.UPDATE_NICKNAME)
	data:prop("headId", nil, platformFacade, PlatformConstants.UPDATE_HEADID)
	data:prop("headStr", nil, platformFacade, PlatformConstants.UPDATE_HEADSTR)
	data:prop("gender", nil, platformFacade, PlatformConstants.UPDATE_GENDER)
	data:prop("mobile", nil, platformFacade, PlatformConstants.UPDATE_MOBILE)
	data:prop("sign", nil, platformFacade, PlatformConstants.UPDATE_SIGNATURE)
	data:prop("gold", nil, platformFacade, PlatformConstants.UPDATE_GOLD)
	data:prop("safeGold", nil, platformFacade, PlatformConstants.UPDATE_SAFEGOLD)
	data:prop("roomCard", nil, platformFacade, PlatformConstants.UPDATE_ROOMCARD)
	data:prop("diamond", nil, platformFacade, PlatformConstants.UPDATE_DIAMOND)
	data:prop("exp", nil, platformFacade, PlatformConstants.UPDATE_EXPERIENCE)
	data:prop("vipLevel", nil, platformFacade, PlatformConstants.UPDATE_VIPLEVEL)
	data:prop("regTime", "")
    data:prop("bSafePwdSet",false, platformFacade, PlatformConstants.UPDATE_SETSAFEPASS) --是否已经设置银行保险箱密码
    data:prop("bRealNameSet", false, platformFacade, PlatformConstants.UPDATE_SETREALNAME)  --是否已经实名认证
    data:prop("bMobileBind", false, platformFacade, PlatformConstants.UPDATE_MOBILEBIND)       --是否绑定手机
    data:prop("bAgcBelong", false, platformFacade, PlatformConstants.UPDATE_AGCBELONG)       --是否有代理归属
	self:setData(data)
end

function UserInfoProxy:onRegister()
	local tarslib = cc.load("jfutils").Tars
	local path = cc.FileUtils:getInstance():fullPathForFilename("platform/components/userinfo/tars/UserInfoHttpProto.tars")
	tarslib.register(path)
end

function UserInfoProxy:onRemove()
end

return UserInfoProxy