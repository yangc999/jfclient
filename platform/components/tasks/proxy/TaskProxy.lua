--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local TaskProxy = class("TaskProxy", Proxy)

function TaskProxy:ctor()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	TaskProxy.super.ctor(self, "TaskProxy")
	local data = ProxyData.new()
	data:prop("taskID", "", platformFacade, PlatformConstants.REQUEST_TASKSHARE_ID)
    data:prop("taskInfo", {},platformFacade, PlatformConstants.UPDATE_TASKSHARE_INFO)
    data:prop("friendCode","") --朋友邀请码
    data:prop("visitCodeTaskID",-1) --邀请码的任务ID
	self:setData(data)
end

function TaskProxy:onRegister()
	--local tarslib = cc.load("jfutils").Tars
	--local path1 = cc.FileUtils:getInstance():fullPathForFilename("platform/components/Task/tars/TaskHttpProto.tars")
	--tarslib.register(path1)
end

function TaskProxy:onRemove()
end

return TaskProxy


--endregion
