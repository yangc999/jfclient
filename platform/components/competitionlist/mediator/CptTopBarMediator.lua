local CptTopBarMediator=class("CptTopBarMediator",cc.load("puremvc").Mediator)

function CptTopBarMediator:ctor(root)
   CptTopBarMediator.super.ctor(self, "CptTopBarMediator")
   self.root=root
end

function CptTopBarMediator:listNotificationInterests()
   local PlatformConstants = cc.exports.PlatformConstants
   return {
   PlatformConstants.UPDATE_COMPETITIONGAMELIST,
   PlatformConstants.UPDATE_DIAMOND,
   PlatformConstants.UPDATE_ROOMCARD,
   PlatformConstants.UPDATE_GOLD,
   PlatformConstants.UPDATE_HEADSTR,
   PlatformConstants.UPDATE_NICKNAME,
   }
end

function CptTopBarMediator:onRegister()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
    --关闭按钮
    local btn_back = seekNodeByName(self.root, "btn_back")
    btn_back:addClickEventListener(function ()
        platformFacade:removeMediator("CompetitionListMediator")
    end)
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
    --钻石面板
    local diamond_panel = seekNodeByName(self.root, "img_diamond_bg")
    if diamond_panel then
        diamond_panel:addClickEventListener(function()
            platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER, 2)  --启动商城钻石页面
        end)
        local btn_adddiamond = seekNodeByName(diamond_panel, "btn_adddiamond")
        if btn_adddiamond then
            btn_adddiamond:addClickEventListener(function()
                platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER, 2)  
            end)
        end
        self.txtDiamond = seekNodeByName(self.root, "userdiamond")
        if userinfo:getData().diamond then
            self.txtDiamond:setString(userinfo:getData().diamond)
        else
            self.txtDiamond:setString(tostring(0))
        end
    end

    --房卡面板
    local fangka_panel = seekNodeByName(self.root, "img_fangka_bg")
    if fangka_panel then
       fangka_panel:addClickEventListener(function()
         platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER, 3)  --启动商城房卡页面
       end)
       local btn_AddRoomCard = seekNodeByName(fangka_panel, "btn_addfangka")
       if btn_AddRoomCard then
          btn_AddRoomCard:addClickEventListener(function()
         platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER, 3)  
       end)
       end
       self.txtRoomCard = seekNodeByName(self.root, "userfangka")
	   if userinfo:getData().roomCard then
		  self.txtRoomCard:setString(userinfo:getData().roomCard)
	   end
    end

   --金币面板
    local money_panel = seekNodeByName(self.root, "img_jidou_bg_0")
    if money_panel then
        money_panel:addClickEventListener(function()
         platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER, 4)  --启动商城金币页面
        end)
        local btn_AddCoin = seekNodeByName(money_panel, "btn_addjindou")
        if btn_AddCoin then
          btn_AddCoin:addClickEventListener(function()
         platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER, 4)  
        end)
        end
        self.usermoney = seekNodeByName(money_panel, "usermoney")
        if userinfo:getData().gold then
          local goldStr = cc.exports.formatLongNum(userinfo:getData().gold)
          self.usermoney:setString(goldStr)
        else
          self.usermoney:setString(tostring(0))
        end
    end

    --头像监听
	local btn_headimg = seekNodeByName(self.root, "btn_headimg")
	if btn_headimg then
		btn_headimg:addClickEventListener(function(btn)
			local scene = platformFacade:retrieveMediator("HallMediator").scene
			platformFacade:sendNotification(PlatformConstants.SHOW_USERINFO, scene)
		end)
    end
	self.imgHead = btn_headimg
	if userinfo:getData().headStr and string.len(userinfo:getData().headStr) > 0 then
		self.imgHead:loadTexture(userinfo:getData().headStr)
	else
		local id = userinfo:getData().headId or 0
		local img = string.format("%s%d.png", id < 6 and "boy" or "girl", id < 6 and id or id-6)
		local path = "platform_res/common/" .. img
		self.imgHead:loadTexture(path)
	end

    --用户名
    self.txtName = seekNodeByName(self.root, "nickname")
	if userinfo:getData().nickName then
		self.txtName:setString(userinfo:getData().nickName)
	end
end

function CptTopBarMediator:handleNotification(notification)
    local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    if name == PlatformConstants.UPDATE_NICKNAME then  --更新昵称消息
		self.txtName:setString(tostring(body))
    elseif name == PlatformConstants.UPDATE_HEADID then
		local id = body or 0
		local img = string.format("%s%d.png", id < 6 and "boy" or "girl", id < 6 and id or id-6)
		local path = "platform_res/common/" .. img
		self.imgHead:loadTexture(path)
	elseif name == PlatformConstants.UPDATE_HEADSTR then --更新头像
  		if body and string.len(body) > 1 then
  			self.imgHead:loadTexture(body)
  		end
	elseif name == PlatformConstants.UPDATE_DIAMOND then --更新钻石消息
		  local diamondStr = cc.exports.formatLongNum(body)
      self.txtDiamond:setString(diamondStr)
	elseif name == PlatformConstants.UPDATE_ROOMCARD then --更新房卡消息
      local roomCardStr = cc.exports.formatLongNum(body)
		  self.txtRoomCard:setString(roomCardStr)
  elseif name == PlatformConstants.UPDATE_GOLD then --更新金币消息
      local goldStr = cc.exports.formatLongNum(body)
      self.usermoney:setString(goldStr)
  end
end
function CptTopBarMediator:onRemove()
end


return CptTopBarMediator