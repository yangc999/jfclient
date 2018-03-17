
local Mediator = cc.load("puremvc").Mediator
local GameListMediator = class("GameListMediator", Mediator)
local tGameIdTemp = {10306600,90010500,12302300,123023001,70020600,80009401}

function GameListMediator:ctor(root)
	GameListMediator.super.ctor(self, "GameListMediator", root)
end	

function GameListMediator:buildGameList(tGameList)
   -- 
   local tLen = #tGameList
   local tResult = {}
   local tTemp = {}
   local tMax = ""
   
   for i = 1, tLen/2 do
      tTemp = {fir = tGameList[i], sec = tGameList[i+1]}
      table.insert(tResult, tTemp)
   end
   if tLen%2 ~=0 then
      tTemp = {fir = tGameList[tLen], sec = nil}
      table.insert(tResult, tTemp)
   end
   return tResult
end

function GameListMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.START_LOGOUT, 
		PlatformConstants.SHOW_GAMELIST, 
		PlatformConstants.SHOW_ROOMLIST, 
		PlatformConstants.UPDATE_PUBGAMELIST, 
	}
end

function GameListMediator:onRegister()
    print("GameListMediator:onRegister")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	local root = self:getViewComponent()
	
	local btnPrivate = seekNodeByName(root, "Btn_private")
	btnPrivate:setZoomScale(-0.05)
	btnPrivate:addClickEventListener(function()
		platformFacade:sendNotification(PlatformConstants.SHOW_PRIVATEROOM)
	end)

	self.list = seekNodeByName(root, "ListView")
	self.list:setScrollBarEnabled(false)
	self.template = seekNodeByName(root, "Panel_temp")
    self.template:setVisible(false)

	local proxy = platformFacade:retrieveProxy("GameListProxy")
	local games = proxy:getData().public
    dump(games, "public games")
	local count = 0
	local gameItem
	for gameId,_ in pairs(games) do
        print("for gameId:" .. gameId)
		count = (count+1)%2
		if count == 1 then
			gameItem = self.template:clone()
			gameItem:setVisible(true)
			list:pushBackCustomItem(gameItem)
		end
		local imgGameItem = seekNodeByName(gameItem, "game_temp_"..count)
		imgGameItem:setVisible(true)
		local path = string.format("platform_res/hall/gamelistbig/game_%s.png", gameId)
		if not cc.FileUtils:getInstance():isFileExist(path) then
			path = "platform_res/hall/gamelistbig/game_2.png"
		end
		imgGameItem:loadTexture(path)
		imgGameItem:addClickEventListener(function()
			platformFacade:sendNotification(PlatformConstants.UPDATE_ROOMLIST, gameId)
		end)
	end
end

function GameListMediator:onRemove()
end

function GameListMediator:updateGameList(body)
        print("GameListMediator:updateGameList()")
        local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	    local PlatformConstants = cc.exports.PlatformConstants
		self.list:removeAllChildren()
		local count = 0
        local count_temp = 0
		local gameItem = nil
        local imgGameItem1 = nil
        local imgGameItem2 = nil
        local tGameIdList = {}
        local lenGame = 0
        dump(body, "games")
        if body == nil then  --空表
           print("游戏列表为空")
           tGameIdList = self:buildGameList(tGameIdTemp)
        else
           for gameId,_ in pairs(body) do
                table.insert(tGameIdList, gameId)
           end
           lenGame = #tGameIdList
           dump(tGameIdList,"body tGameIdList")
           print("lenGame = "..lenGame)
           if  lenGame<6 then
              for i =1, 6-lenGame do
                  table.insert(tGameIdList, tGameIdTemp[i])
              end
           end
        end
        tGameIdList = self:buildGameList(tGameIdList)
        dump(tGameIdList, "tGameList 列表")
        --for _, game in ipairs(tGameIdList) do
          
          for i=1,#tGameIdList do
            local game = tGameIdList[i]
            dump(game, "tGameIdList[i]")
            gameItem = self.template:clone()
			gameItem:setVisible(true)
			self.list:pushBackCustomItem(gameItem)
            imgGameItem1 = seekNodeByName(gameItem, "game_temp_1")
			imgGameItem1:setVisible(true)
			local path = string.format("platform_res/hall/gamelistbig/game_%d.png", game.fir)
            print("game path:" .. path)
			if not cc.FileUtils:getInstance():isFileExist(path) then
                print("not found game path:"..path)
				path = "platform_res/hall/gamelistbig/game_x.png"
			end
			imgGameItem1:loadTexture(path)
            local imgOnline = seekNodeByName(imgGameItem1, "img_online")
            if i<=lenGame then             
               imgGameItem1:addClickEventListener(function()
               print("platformFacade:sendNotification(PlatformConstants.UPDATE_ROOMLIST, " .. game.fir.. ")")
			   platformFacade:sendNotification(PlatformConstants.UPDATE_ROOMLIST, game.fir)
               --platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "功能待开放")
			   end)
               imgOnline:setVisible(false)
            else
               imgOnline:setVisible(true)
               imgGameItem1:addClickEventListener(function()
			--platformFacade:sendNotification(PlatformConstants.UPDATE_ROOMLIST, gameId)
               print("待开放游戏")
               platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "功能待开放")
			   end)
            end
			

            imgGameItem2 = seekNodeByName(gameItem, "game_temp_0")
			imgGameItem2:setVisible(true)
			local path2 = string.format("platform_res/hall/gamelistbig/game_%d.png", game.sec)
            print("game path:" .. path2)
			if not cc.FileUtils:getInstance():isFileExist(path2) then
                print("not found game path:"..path2)
				path2 = "platform_res/hall/gamelistbig/game_x.png"
			end
			imgGameItem2:loadTexture(path2)
            local imgOnline2 = seekNodeByName(imgGameItem2, "img_online")
			if i+1<=lenGame then
               
               imgGameItem2:addClickEventListener(function()
			   platformFacade:sendNotification(PlatformConstants.UPDATE_ROOMLIST, game.fir)
               --platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "功能待开放")
			   end)
               imgOnline2:setVisible(false)
            else
               imgOnline2:setVisible(true)
               imgGameItem2:addClickEventListener(function()
			--platformFacade:sendNotification(PlatformConstants.UPDATE_ROOMLIST, gameId)
               platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "功能待开放")
			   end)
            end
        end

         -- local imgGameItem = seekNodeByName(gameItem, "game_temp_"..count)
         -- imgGameItem:setVisible(true)
          --return
        --end
        --[[
		for gameId,_ in pairs(body) do
			count = (count+1)%2
			if count == 1 then
				gameItem = self.template:clone()
				gameItem:setVisible(true)
				self.list:pushBackCustomItem(gameItem)
			end
			local imgGameItem = seekNodeByName(gameItem, "game_temp_"..count)
			imgGameItem:setVisible(true)
			local path = string.format("platform_res/hall/gamelistbig/game_%s.png", gameId)
			if not cc.FileUtils:getInstance():isFileExist(path) then
				path = "platform_res/hall/gamelistbig/game_x.png"
			end
			imgGameItem:loadTexture(path)
			imgGameItem:addClickEventListener(function()
				platformFacade:sendNotification(PlatformConstants.UPDATE_ROOMLIST, gameId)
			end)
		end
        --]]
end

function GameListMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.START_LOGOUT then
		platformFacade:removeMediator("GameListMediator")
	elseif name == PlatformConstants.SHOW_GAMELIST then
		self:getViewComponent():setVisible(true)
	elseif name == PlatformConstants.SHOW_ROOMLIST then
		self:getViewComponent():setVisible(false)
	elseif name == PlatformConstants.UPDATE_PUBGAMELIST then
        print("UPDATE_PUBGAMELIST")
        self:updateGameList(body)
	end
end

return GameListMediator