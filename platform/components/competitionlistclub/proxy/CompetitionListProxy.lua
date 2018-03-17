
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local CompetitionListProxy = class("CompetitionListProxy", Proxy)

function CompetitionListProxy:ctor()
	CompetitionListProxy.super.ctor(self, "CompetitionListProxy")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	local data = ProxyData.new()
	data:prop("currentMatchList", {}, platformFacade, PlatformConstants.UPDATE_SHOWCOMPETITIONLIST)
	data:prop("showFrom", 0)
	data:prop("showTo", 0)
	data:prop("templateIdList", {})
    data:prop("matchIdList", {})
    data:prop("playersList", {})
    data:prop("templateIdTomatchIdList", {}, platformFacade, PlatformConstants.UPDATE_COMPETITIONLISTPLAYERNUM)
    
	self:setData(data)
end

function CompetitionListProxy:onRegister()
	local tarslib = cc.load("jfutils").Tars
	local path = cc.FileUtils:getInstance():fullPathForFilename("platform/components/competitionlist/tars/GameMatchProto.tars")
	tarslib.register(path)
	
end

function CompetitionListProxy:onRemove()
end

function CompetitionListProxy:present()
	local templateIdList = {}
    local templateIdTomatchIdList = {}
    for i,v in ipairs(self:getData().currentMatchList) do
    templateIdList[i]=v.templateId
    templateIdTomatchIdList[v.templateId]={}
    templateIdTomatchIdList[v.templateId]["numOfPlayer"]=0
    templateIdTomatchIdList[v.templateId]["matchId"]=v.matchId
    end
	self:getData().templateIdList = templateIdList
    self:getData().templateIdTomatchIdList=templateIdTomatchIdList
    
end

return CompetitionListProxy