--region *.lua
--Date
--商城的UI

local Mediator = cc.load("puremvc").Mediator
local ShopMediator = class("ShopMediator", Mediator)
local ShopListMediator = import(".ShopListMediator")
local ShopProxy = import("..proxy.ShopProxy")

function ShopMediator:ctor(curType)
  	ShopMediator.super.ctor(self, "ShopMediator")
  	self.scene = nil
    self.currId = curType                   --当前栏目ID ， 1. 人民币 2 钻石 ， 3 房卡  , 4 金币
    self.oldTypeItem = nil                --上次选中的列表标题项
end
--造钻石假数据
function ShopMediator:buildDiamondList()
   local diamondList = {}
   local diamond1 = {id="1",title="6钻石",icon = "diamond_1.png", payType=1, payValue = 10, gainType=2, gainValue=6}
   local diamond2 = {id="2", title = "12钻石", icon = "diamond_2.png", payType=1, payValue = 20, gainType=2, gainValue = 12}
   local diamond3 = {id="3", title = "18钻石", icon = "diamond_3.png", payType=1, payValue = 30, gainType=2, gainValue = 18}
   local diamond4 = {id="4", title = "30钻石", icon = "diamond_4.png", payType=1, payValue = 100, gainType=2, gainValue = 30}
   local diamond5 = {id="5", title = "68钻石", icon = "diamond_4.png", payType=1, payValue = 300, gainType=2, gainValue = 68}
   local diamond6 = {id="6", title = "128钻石", icon = "diamond_4.png", payType=1, payValue = 400, gainType=2, gainValue = 128}
   local diamond7 = {id="7", title = "328钻石", icon = "diamond_5.png", payType=1, payValue = 800, gainType=2, gainValue = 328}
   local diamond8 = {id="8", title = "628钻石", icon = "diamond_6.png", payType=1, payValue = 1200, gainType=2, gainValue = 648}
   table.insert(diamondList, diamond1)
   table.insert(diamondList, diamond2)
   table.insert(diamondList, diamond3)
   table.insert(diamondList, diamond4)
   table.insert(diamondList, diamond5)
   table.insert(diamondList, diamond6)
   table.insert(diamondList, diamond7)
   table.insert(diamondList, diamond8)
   return diamondList
end

--造房卡假数据
function ShopMediator:buildRoomCardList()
   local roomList = {}
   local room1 = {id="1",title="6房卡",icon = "fangka1.png", payType=1, payValue = 10, gainType=3, gainValue=6}
   local room2 = {id="2", title = "12房卡", icon = "fangka2.png", payType=1, payValue = 20, gainType=3, gainValue = 12}
   local room3 = {id="3", title = "18房卡", icon = "fangka3.png", payType=1, payValue = 30, gainType=3, gainValue = 18}
   local room4 = {id="4", title = "30房卡", icon = "fangka4.png", payType=1, payValue = 50, gainType=3, gainValue = 30}
   local room5 = {id="5", title = "68房卡", icon = "fangka5.png", payType=1, payValue = 300, gainType=3, gainValue = 68}
   local room6 = {id="6", title = "128房卡", icon = "fangka4.png", payType=1, payValue = 400, gainType=3, gainValue = 128}
   local room7 = {id="7", title = "328房卡", icon = "fangka5.png", payType=1, payValue = 800, gainType=3, gainValue = 328}
   local room8 = {id="8", title = "628房卡", icon = "fangka5.png", payType=1, payValue = 1200, gainType=3, gainValue = 648}
   local room9 = {id="9",title="6房卡",icon = "fangka1.png", payType=1, payValue = 10, gainType=3, gainValue=6}
   local room10 = {id="10", title = "12房卡", icon = "fangka2.png", payType=1, payValue = 20, gainType=3, gainValue = 12}
   local room11 = {id="11", title = "18房卡", icon = "fangka3.png", payType=1, payValue = 30, gainType=3, gainValue = 18}
   local room12 = {id="12", title = "30房卡", icon = "fangka4.png", payType=1, payValue = 100, gainType=3, gainValue = 30}
   table.insert(roomList, room1)
   table.insert(roomList, room2)
   table.insert(roomList, room3)
   table.insert(roomList, room4)
   table.insert(roomList, room5)
   table.insert(roomList, room6)
   table.insert(roomList, room7)
   table.insert(roomList, room8)
   table.insert(roomList, room9)
   table.insert(roomList, room10)
   table.insert(roomList, room11)
   table.insert(roomList, room12)
   return roomList
end

--造金币假数据
function ShopMediator:buildGoldList()
   local coinList = {}
   local coin1 = {id="1",title="3万金币",icon = "golds1.png", payType=2, payValue = 10, gainType=4, gainValue=6}
   local coin2 = {id="2", title = "6万金币", icon = "golds2.png", payType=2, payValue = 20, gainType=4, gainValue = 12}
   local coin3 = {id="3", title = "18万金币", icon = "golds3.png", payType=2, payValue = 30, gainType=4, gainValue = 18}
   local coin4 = {id="4", title = "50万金币", icon = "golds4.png", payType=2, payValue = 100, gainType=4, gainValue = 30}
   local coin5 = {id="5", title = "100万金币", icon = "golds5.png", payType=2, payValue = 300, gainType=4, gainValue = 68}
   local coin6 = {id="6", title = "200万金币", icon = "golds4.png", payType=2, payValue = 400, gainType=4, gainValue = 128}
   local coin7 = {id="7", title = "300万金币", icon = "golds5.png", payType=2, payValue = 800, gainType=4, gainValue = 328}
   local coin8 = {id="8", title = "500万金币", icon = "golds6.png", payType=2, payValue = 1200, gainType=4, gainValue = 648}
   local coin9 = {id="9", title = "300万金币", icon = "golds5.png", payType=2, payValue = 800, gainType=4, gainValue = 328}
   local coin10 = {id="10", title = "500万金币", icon = "golds6.png", payType=2, payValue = 1200, gainType=4, gainValue = 648}
   table.insert(coinList, coin1)
   table.insert(coinList, coin2)
   table.insert(coinList, coin3)
   table.insert(coinList, coin4)
   table.insert(coinList, coin5)
   table.insert(coinList, coin6)
   table.insert(coinList, coin7)
   table.insert(coinList, coin8)
   table.insert(coinList, coin9)
   table.insert(coinList, coin10)
   return coinList
end
function ShopMediator:listNotificationInterests()
    local PlatformConstants = cc.exports.PlatformConstants
	return {
      PlatformConstants.START_LOGOUT,
		  PlatformConstants.UPDATE_SHOPCOINLIST, 
      PlatformConstants.UPDATE_SHOPDIAMONDLIST,
      PlatformConstants.UPDATE_SHOPFANGKALIST,
      PlatformConstants.SHOW_SHOPLIST,
      PlatformConstants.UPDATE_HEADID, 
  		PlatformConstants.UPDATE_HEADSTR, 
  		PlatformConstants.UPDATE_GOLD, 
  		PlatformConstants.UPDATE_ROOMCARD,
      PlatformConstants.UPDATE_DIAMOND,
      PlatformConstants.RESULT_SHOPDIAMONDBUY,
      PlatformConstants.WXPAY_OK,
      PlatformConstants.ALIPAY_OK,
      PlatformConstants.WXPAY_FAILED,
      PlatformConstants.ALIPAY_FAILED,
	}
end

--设置当前选中的项的状态图片
function ShopMediator:setSelectedTypeState(curItem)
    curItem:loadTexture("platform_res/shop/btn-2.png") --设置为选中状态图标
    local txtName = seekNodeByName(curItem, "txtName") --设置名字颜色
    if txtName then
        txtName:setTextColor(cc.c3b(255, 255, 255)) --设置字体颜色为白色
    end
end

function ShopMediator:setOldTypeState()
    --老的选中项目设为不选中
    if self.oldTypeItem~=nil then
         self.oldTypeItem:loadTexture("platform_res/shop/btn-1.png") --设置为选中状态图标
         local txtName = seekNodeByName(self.oldTypeItem, "txtName") --设置名字颜色
        if txtName then
           txtName:setTextColor(cc.c3b(104,161,222))
        end
    end
end

function ShopMediator:onRegister()
    print("ShopMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	  local PlatformConstants = cc.exports.PlatformConstants
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
    local shopProxy = platformFacade:retrieveProxy("ShopProxy")

    platformFacade:registerCommand(PlatformConstants.REQUEST_SHOPLISTBYID, cc.exports.RequestShopListCommand)

    local ui = cc.CSLoader:createNode("hall_res/mall/mallLayer.csb")  --设置UI的csb
	  self:setViewComponent(ui)
    local scene = platformFacade:retrieveMediator("HallMediator").scene --获取要加载上的场景 (大厅所在的场景)
	  scene:addChild(self:getViewComponent()) --获取大厅的Mediator，加载这个公告场景
    self.scene = scene

    self.bg = seekNodeByName(ui, "mall_bg")   --获取背景
    -- self.bgTop = seekNodeByName(self.bg, "mall_top")  --顶部栏
    -- if self.bgTop == nil then
    --    print("bgTop is nil")
    -- end
    self.bgLeft =  seekNodeByName(self.bg, "mall_left")  --左边栏
     if self.bgLeft == nil then
       print("bgLeft is nil")
    end
    --获取返回按钮
    local btnBack = seekNodeByName(ui, "btn_back")
    if btnBack == nil then
       print("btnBack is nil")
    end
	if btnBack then
		btnBack:addClickEventListener(function()
            print("click btnBack")
            btnBack:setZoomScale(-0.1)
			platformFacade:removeMediator("ShopMediator")
		end)
	end

    --获取左边列金币按钮
    self.imgCoinType = seekNodeByName(self.bgLeft, "item_coin")
    if self.imgCoinType==nil then
       print("self.imgCoinType is nil")
    end
    --获取左边钻石列表
    self.imgDiamondType = seekNodeByName(self.bgLeft, "item_diamond")
    if self.imgDiamondType==nil then
       print("self.imgDiamondType is nil")
    end
    --获取左边房卡列表
    self.imgFangKaType = seekNodeByName(self.bgLeft, "item_fangka")
    if self.imgFangKaType==nil then
       print("self.imgFangKaType is nil")
    end
    --点击金币按钮
    if self.imgCoinType then
        self.imgCoinType:addClickEventListener(function()
            print("点击金币按钮")
            --当前已经是金币栏，直接返回
            if self.currId == 4 then
               return
            end
            self.currId = 4
			self:setSelectedTypeState(self.imgCoinType)
            --老的选中项目设为不选中
            self:setOldTypeState()
            self.oldTypeItem = self.imgCoinType
            local listGold = shopProxy:getData().coinlist
            if #listGold<=0 then  --没有金币列表数据
               --发送请求金币列表请求
               platformFacade:sendNotification(PlatformConstants.REQUEST_SHOPLISTBYID, 4)
            else --有金币列表数据，直接显示
               platformFacade:sendNotification(PlatformConstants.SHOW_SHOPLIST)
            end
		end)
    end

    --点击钻石按钮
    if self.imgDiamondType then
       self.imgDiamondType:addClickEventListener(function()
            print("点击钻石按钮")
            --当前已经是钻石栏，直接返回
            if self.currId == 2 then
               return
            end
			self:setSelectedTypeState(self.imgDiamondType)
            self.currId = 2
            --老的选中项目设为不选中
            self:setOldTypeState()
            self.oldTypeItem = self.imgDiamondType

            local listDiamond = shopProxy:getData().diamondlist
            if #listDiamond<=0 then  --没有钻石列表数据
               --发送请求钻石列表请求
               platformFacade:sendNotification(PlatformConstants.REQUEST_SHOPLISTBYID, 2)
            else --有钻石列表数据，直接显示
               platformFacade:sendNotification(PlatformConstants.SHOW_SHOPLIST)
            end
           
		end)
    end

        --点击房卡按钮
    if self.imgFangKaType then
        self.imgFangKaType:addClickEventListener(function()
            print("点击房卡按钮")
            --当前已经是房卡栏，直接返回
            if self.currId == 3 then
               return
            end
            self.currId = 3
			self:setSelectedTypeState(self.imgFangKaType)
            --老的选中项目设为不选中
            self:setOldTypeState()
            self.oldTypeItem = self.imgFangKaType

            local listRoomCard = shopProxy:getData().fangkalist
            local lenFanCard = #listRoomCard
            print("lenFanCard:" .. lenFanCard)
            if #listRoomCard<=0 then  --没有钻石列表数据
               --发送请求房卡列表请求
               platformFacade:sendNotification(PlatformConstants.REQUEST_SHOPLISTBYID, 3)
            else --有房卡列表数据，直接显示
               platformFacade:sendNotification(PlatformConstants.SHOW_SHOPLIST)
            end
           --[[shopProxy:getData().curlist = self:buildRoomCardList()
           dump(shopProxy:getData().curlist, "roomCardList")
           --self:showGoodsListView(list, 4)
           shopProxy:getData().reqType = 3
           platformFacade:sendNotification(PlatformConstants.UPDATE_SHOPLIST)
           --]]
		end)
    end

    --默认左边栏选择金币商品
    --self.currId = 4
    if self.currId == 4 then --如果默认选择是金币
       self:setSelectedTypeState(self.imgCoinType)
       --老的选中项目设为不选中
       self:setOldTypeState()
       self.oldTypeItem = self.imgCoinType
    elseif self.currId == 3 then --如果默认选择进入是房卡
       self:setSelectedTypeState(self.imgFangKaType)
       --老的选中项目设为不选中
       self:setOldTypeState()
       self.oldTypeItem = self.imgFangKaType
    elseif self.currId == 2 then --钻石
       self:setSelectedTypeState(self.imgDiamondType)
       self:setOldTypeState()
       self.oldTypeItem = self.imgDiamondType
    end
    
    --发送请求商品列表请求
    platformFacade:sendNotification(PlatformConstants.REQUEST_SHOPLISTBYID, self.currId)
    --获取商品列表控件
    self.goodtList = self.bg:getChildByName("Panel_1"):getChildByName("FileNode_1")
    self.goodtList:removeAllChildren()
    --默认显示金币列表
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local goldlist =  self:buildGoldList() -- shopProxy:getData().coinlist -- self:buildGoldList()
    --shopProxy:getData().curlist = goldlist
    shopProxy:getData().reqType = self.currId
	platformFacade:registerMediator(ShopListMediator.new(self.goodtList))   --注册ShopListMediator

    --获取玩家头像
    self.imgHead = seekNodeByName(ui, "btn_headimg")
	if userinfo:getData().headStr and string.len(userinfo:getData().headStr) > 0 then
		self.imgHead:loadTexture(userinfo:getData().headStr)
	else
		local id = userinfo:getData().headId or 0
		local img = string.format("%s%d.png", id < 6 and "boy" or "girl", id < 6 and id or id-6)
		local path = "platform_res/common/" .. img
		self.imgHead:loadTexture(path)
	end

    --昵称
	self.txtName = seekNodeByName(ui, "nickname")
    --设置左对齐，0：左对齐，1：居中， 2：右对齐
    self.txtName:setTextHorizontalAlignment(0)
	if userinfo:getData().nickName then
		self.txtName:setString(userinfo:getData().nickName)
	end
  
  --金币面板
  local gold_panel = seekNodeByName(ui, "img_jidou_bg")
  if gold_panel then
      local btnAddGold = seekNodeByName(ui, "btn_addjindou")
      if btnAddGold then
          btnAddGold:setVisible(false)
      end
      self.txtGold = seekNodeByName(ui, "usermoney")
      if userinfo:getData().gold then
          local goldStr=cc.exports.formatLongNum(userinfo:getData().gold)
          self.txtGold:setString(goldStr)
      else
          self.txtGold:setString(0)
      end
  end

  --钻石面板
  local diamond_panel = seekNodeByName(ui, "img_diamond_bg")
  if diamond_panel then
      local btnAddDiamond = seekNodeByName(ui, "btn_adddiamond")
      if btnAddDiamond then
          btnAddDiamond:setVisible(false)
      end
      self.txtDiamond = seekNodeByName(ui, "userdiamond")
      if userinfo:getData().diamond then
          local diamondStr=cc.exports.formatLongNum(userinfo:getData().diamond)
          self.txtDiamond:setString(diamondStr)
      else
          self.txtDiamond:setString(0)
      end
  end

  --房卡面板
  local fangka_panel = seekNodeByName(ui, "img_fangka_bg")
  if fangka_panel then
      local btnAddFangka = seekNodeByName(ui, "btn_addfangka")
      if btnAddFangka then
          btnAddFangka:setVisible(false)
      end
      self.txtRoomCard = seekNodeByName(ui, "userfangka")
      if userinfo:getData().roomCard then
          local roomCardStr=cc.exports.formatLongNum(userinfo:getData().roomCard)
          self.txtRoomCard:setString(roomCardStr)
      else
          self.txtRoomCard:setString(0)
      end
  end
end

--显示商品列表
--[[
function ShopMediator:showGoodsListView(list, nType)
   print("start tzShopLayer:showYuanbaoListPage")
   local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
   --获取商品列表控件
    self.goodtList = self.bg:getChildByName("Panel_1"):getChildByName("FileNode_1")
    --self.goodtList:removeAllChildren()
    platformFacade:removeMediator("ShopListMediator")

    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerMediator(ShopListMediator.new(self.goodtList, list, nType))   --注册BankMediator
end
--]]
--[[
--显示商品列表
function ShopMediator:showGoodsListPage(list, nType)
   print("start tzShopLayer:showYuanbaoListPage")
   --获取商品列表控件
    self.goodtList = self.bg:getChildByName("Panel_1"):getChildByName("FileNode_1")
    self.goodtList:removeAllChildren()
    --根据类型的不同加载相应的csb
    local strBg = ""
    local node = nil
    local strType = ""
    if nType == 2 then --钻石
      strBg="yuanbao"
      strType = "钻石"
      node = cc.CSLoader:createNode("hall_res/mall/mall_yuanbao.csb")
	  self.goodtList:addChild(node)
    elseif nType == 3 then --房卡
      strBg="fangka"
      strType = "房卡"
      node = cc.CSLoader:createNode("hall_res/mall/mall_fangka.csb")
	  self.goodtList:addChild(node)
    elseif nType == 4 then  --金币
      strBg="yuanbao"
      strType = "金币"
      node = cc.CSLoader:createNode("hall_res/mall/mall_exchange.csb")
	  self.goodtList:addChild(node)
    end
    --寻找原来的8个节点
    for i = 1,8 do
        local nodeName = strBg .. "_" .. tostring(i)
        print("nodeName:" .. nodeName)
		local list_itemone = seekNodeByName(node, nodeName)
		list_itemone:setVisible(false)
	end
    --获取列表长度
    local listsize = #list
	if listsize<1 then 
		--如果列表是null的，请求列表
		--self:requestYuanbaoList(4)
        return;
	end
    if listsize>8 then listsize = 8 end
    --根据列表的数据来设置每一项
    for i=1,listsize do
        local nodeName = strBg .. "_" .. tostring(i)
		local list_itemone = seekNodeByName(node, nodeName)
        local strIcon = list[i].icon
		if list_itemone ~= nil then
			list_itemone:setVisible(true)
            --顶部商品数字， 如10房卡
            local toptipNum = list_itemone:getChildByName("buy_tip_num")
            --local strZuan = g_strZuan or "钻石"
            toptipNum:setString(list[i].gainValue..strType)

            local goodIcon = list_itemone:getChildByName("yuanbaoimg") --图标
            --设置图标
            if goodIcon then
                if strIcon~="" then
                   local iconFrame = display.newSpriteFrame("platform_res/mark/"..strIcon)
                   if iconFrame~=nil then
                     goodIcon:setDisplayFrame(iconFrame)
                   end
                end
            end

			local btn_buy = list_itemone:getChildByName("btn_buy_1")
            
			if btn_buy ~= nil then
				btn_buy:setVisible(true)
				btn_buy:setTag(list[i].id)
				--购买按钮监听
				btn_buy:addClickEventListener(function(btn,event)
                               
							end)
				
                local price_num = btn_buy:getChildByName("price_white_num")
				price_num:setString(list[i].payValue)  --设置支付金额
			end
		end
	end
    print("end ShopLayer:showGoodsListPage")
end
--]]

function ShopMediator:handleNotification(notification)
    print("ShopMediator:handleNotification")
    local name = notification:getName()
    local body = notification:getBody()
	  local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	  local PlatformConstants = cc.exports.PlatformConstants
    local shopProxy = platformFacade:retrieveProxy("ShopProxy")
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
    local nType = shopProxy:getData().reqType  --得到那请求商品类型
    local list = {}
	if name == PlatformConstants.START_LOGOUT then
		platformFacade:removeMediator("ShopMediator")
        platformFacade:removeProxy("ShopProxy")
    elseif name == PlatformConstants.UPDATE_SHOPCOINLIST then
        -- self:showAnnounceList()  --显示公告列表
    elseif name == PlatformConstants.UPDATE_SHOPDIAMONDLIST then
        -- self.annId = notification.getBody
    elseif name == PlatformConstants.UPDATE_SHOPFANGKALIST then
      --  local annContent = notification:getBody()
       -- self.curContent = annContent
        --print("handdle notification announce content:" .. annContent)
       -- self:showAnnounceConntent(annContent)
    elseif name == PlatformConstants.SHOW_SHOPLIST then
        if self.currId == 2 then  --获取钻石列表
          list = shopProxy:getData().diamondlist --获取钻石列表
          --shopProxy:getData().curlist = list --self:buildDiamondList()
          dump(list, "DiamondList")
          --self:showGoodsListView(list, 4)
          shopProxy:getData().reqType = 2
          platformFacade:sendNotification(PlatformConstants.UPDATE_SHOPLIST)
        elseif self.currId == 3 then  --获取房卡列表
          list = shopProxy:getData().fangkalist
          --shopProxy:getData().curlist = list --self:buildRoomCardList()
          dump(list, "roomCardList")
           --self:showGoodsListView(list, 4)
          shopProxy:getData().reqType = 3
          platformFacade:sendNotification(PlatformConstants.UPDATE_SHOPLIST)
        elseif self.currId == 4 then --获取金币列表
          list = shopProxy:getData().coinlist
          --shopProxy:getData().curlist = coinlist--self:buildGoldList()  --创建金币商品列表
          dump(list, "coinList")
          --dump(list, "coinList")
           --self:showGoodsListView(list, 4)
          shopProxy:getData().reqType = 4
          platformFacade:sendNotification(PlatformConstants.UPDATE_SHOPLIST)  --发送更新商品列表消息
         end
    elseif name == PlatformConstants.UPDATE_NICKNAME then --更新昵称
          self.txtName:setString(tostring(body))
    elseif name == PlatformConstants.UPDATE_HEADID then --更新头像
  		local id = body or 0
  		local img = string.format("%s%d.png", id < 6 and "boy" or "girl", id < 6 and id or id-6)
  		local path = "platform_res/common/" .. img
  		  self.imgHead:loadTexture(path)
    elseif name == PlatformConstants.UPDATE_HEADSTR then
    		if body and string.len(body) > 1 then
    			 self.imgHead:loadTexture(body)
    		end
    elseif name == PlatformConstants.UPDATE_GOLD then --更新金币
        local goldStr = cc.exports.formatLongNum(body)
		    self.txtGold:setString(goldStr)
	  elseif name == PlatformConstants.UPDATE_ROOMCARD then --更新房卡
        local roomCardStr = cc.exports.formatLongNum(body)
		    self.txtCard:setString(roomCardStr)
    elseif name == PlatformConstants.UPDATE_DIAMOND then --更新钻石
        local diamondStr = cc.exports.formatLongNum(body)
        self.txtDiamond:setString(diamondStr)
    elseif name == PlatformConstants.RESULT_SHOPDIAMONDBUY then --钻石购买结果
       local tBuyResult  = body
       dump(tBuyResult, "钻石购买结果")
       if tBuyResult.succ == true then  --购买成功
          if tBuyResult.iAfterDiamond~=nil then
             --self.txtDiamond:setString(tBuyResult.iAfterDiamond)
             userinfo:getData().diamond = tBuyResult.iAfterDiamond
          end


          if nType == 3 then  --购买的是房卡
             if tBuyResult.lAfterValue~=nil then
                 --self.txtCard:setString(tBuyResult.lAfterValue)
                 userinfo:getData().roomCard = tBuyResult.lAfterValue
             end
          elseif nType == 4 then --购买的是金币
             if tBuyResult.lAfterValue~=nil then
                 --self.txtGold:setString(tBuyResult.lAfterValue)
                 userinfo:getData().gold = tBuyResult.lAfterValue
             end
          end

          cc.exports.showGetAnimation(self:getViewComponent())  --显示获得物品动画

       else  --tBuyResult.succ == false
          if tBuyResult.iRet == 301 then    --钻石余额不足
             print("钻石余额不足")
             local strMsg = "钻石余额不足"
             local tMsg = {mType = 1, code = -1, msg = strMsg}
             platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX_EX, tMsg)
          end
       end
    elseif name == PlatformConstants.WXPAY_OK then --微信购买结果
      cc.exports.showGetAnimation(self:getViewComponent())  --显示获得物品动画

    elseif name == PlatformConstants.ALIPAY_OK then --支付宝购买结果
      cc.exports.showGetAnimation(self:getViewComponent())  --显示获得物品动画
    elseif name == PlatformConstants.WXPAY_FAILED then --微信购买结果
      platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "购买失败，请检查网络。（如有疑问请联系客服XXXXXXXX）")
    elseif name == PlatformConstants.ALIPAY_FAILED then --支付宝购买结果
      platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "购买失败，请检查网络。（如有疑问请联系客服XXXXXXXX）")
	end
end

function ShopMediator:onRemove()
    print("ShopMediator:onRemove")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	platformFacade:removeCommand(PlatformConstants.REQUEST_SHOPLISTBYID)

    platformFacade:removeMediator("ShopListMediator")
    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)

end

return ShopMediator
--endregion
