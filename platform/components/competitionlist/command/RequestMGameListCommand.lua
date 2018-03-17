local RequestMGameListCommand=class("RequestMGameListCommand",cc.load("puremvc").SimpleCommand)
local CptMoreGameProxy=import("..proxy.CptMoreGameProxy")
local HttpSender=cc.load("jfutils").HttpSender
function RequestMGameListCommand:execute()
print("RequestMGameListCommand")
 local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
 local PlatformConstants = cc.exports.PlatformConstants
 if not platformFacade:hasProxy("CptMoreGameProxy") then 
 platformFacade:registerProxy(CptMoreGameProxy.new())
 end
 print("RequestMGameListCommand")
 local cptMoreGameProxy = platformFacade:retrieveProxy("CptMoreGameProxy")
 local sendData = {
		hostId = 10000,
	}
 HttpSender:post({"gamematch","ListMatchConfigGame",104},sendData,function(revData)
        dump(revData,"CptMoreGameProxy",10)
        local temp={}
        temp=cptMoreGameProxy:getData().gameList
        local len1=#revData.matchConfigGameList
        local len2=#cptMoreGameProxy:getData().gameList
        for i=1,len1 do
          if len2>0 then 
            for j=1,len2 do
                if not self:indexOf(cptMoreGameProxy:getData().gameList,revData.matchConfigGameList[i].gameId) then
                   revData.matchConfigGameList[i].selected=false
                   table.insert(temp,revData.matchConfigGameList[i])
                end
            end
          else
             revData.matchConfigGameList[i].selected=false
             table.insert(temp,revData.matchConfigGameList[i])
          end
        end
        platformFacade:retrieveProxy("CptMoreGameProxy"):getData().gameList=temp
   end)
end
function RequestMGameListCommand:indexOf(src,tagrget)
   local len=#src
   for i=1,len do
       if tagrget==src[i].gameId then
        print("oldgame")
        return true
       end
   end
   print("newgame")
   return false
end
return RequestMGameListCommand