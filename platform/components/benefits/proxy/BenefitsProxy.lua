
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local BenefitsProxy = class("BenefitsProxy", Proxy)

function BenefitsProxy:ctor()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	BenefitsProxy.super.ctor(self, "BenefitsProxy")
	local data = ProxyData.new()
	data:prop("taskID", "", platformFacade, PlatformConstants.REQUEST_BENEFITS_INFO)
    data:prop("taskInfo", "", platformFacade, PlatformConstants.UPDATE_TASKINFO)
    data:prop("assistanceTimes", 0, platformFacade, PlatformConstants.UPDATE_ASSISTANCE_TIMES)
    data:prop("assistanceCurrentTimes", 0)
    data:prop("assistanceGold", 0)
	self:setData(data)
end

function BenefitsProxy:onRegister()
	local tarslib = cc.load("jfutils").Tars
	local path1 = cc.FileUtils:getInstance():fullPathForFilename("platform/components/benefits/tars/TaskHttpProto.tars")
	tarslib.register(path1)
end

function BenefitsProxy:onRemove()
end

return BenefitsProxy