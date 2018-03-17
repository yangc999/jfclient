
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local CptListDetailProxy = class("CptListDetailProxy", Proxy)

function CptListDetailProxy:ctor()
	CptListDetailProxy.super.ctor(self, "CptListDetailProxy")
end

function CptListDetailProxy:onRegister()
	
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	local data = ProxyData.new()
    data:prop("matchAwardList", {})
    data:prop("matchAwardListPresent", {
    {start=1,num=1,gainType=1,gainValue=20},
    {start=2,num=3,gainType=1,gainValue=20},
    {start=5,num=7,gainType=2,gainValue=15},
    {start=5,num=7,gainType=1,gainValue=20},
    {start=5,num=7,gainType=1,gainValue=20},
    {start=5,num=7,gainType=1,gainValue=20},
    {start=5,num=7,gainType=1,gainValue=20},
    {start=5,num=7,gainType=1,gainValue=20},
    {start=5,num=7,gainType=1,gainValue=20},
    {start=5,num=7,gainType=1,gainValue=20},
    {start=5,num=7,gainType=1,gainValue=20},
    {start=5,num=7,gainType=3,gainValue=20},
    {start=5,num=7,gainType=1,gainValue=20},
    },PlatformConstants.UPDATE_SHOWCOMPETITIONDETAIL)
	self:setData(data)
end

function CptListDetailProxy:onRemove()
end

function CptListDetailProxy:present()
   local matchAwardListPresent={}
   local count=1
   local matchAwardList=self:getData().matchAwardList

   local len=#matchAwardList
   local i=1
   local j=1
  while i<=len do
   local temp=i
     while j<=len do
        j=i+1
        if(matchAwardList[j].gainType==matchAwardList[i].gainType and matchAwardList[j].gainValue==matchAwardList[i].gainValue) then
           count=count+1
           i=j
        end
        j=j+1
     end
       table.insert(matchAwardListPresent,{start=temp,num=count,gainType=matchAwardList[temp].gainType,gainValue=matchAwardList[temp].gainValue})
       count=1
       i=i+1
   end
   dump(matchAwardListPresent,"matchAwardListPresentss",10)
   self:getData().matchAwardListPresent=matchAwardListPresent
end

return CptListDetailProxy