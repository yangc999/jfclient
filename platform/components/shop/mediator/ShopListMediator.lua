--region *.lua
--Date
--商城商品列表
local Mediator = cc.load("puremvc").Mediator
local ShopListMediator = class("ShopListMediator", Mediator)

local Game_Button_ENABALED = true  --按钮是否可用
local Cell_Size = 8 -- 一栏里有多少个商品

function ShopListMediator:ctor(root)
    print("ShopListMediator:ctor(root)")
	  ShopListMediator.super.ctor(self, "ShopListMediator")
	  self.root = root
      self.curBtnTag = nil
      --self.nType = nType                   --当前栏目ID ， 2 钻石 ， 3 房卡  , 4 金币
      --self.goodsList = goodsList         --商品列表
      self.Template = nil
end

function ShopListMediator:listNotificationInterests()
    local PlatformConstants = cc.exports.PlatformConstants
	return {
        PlatformConstants.SHOW_SHOPLIST, 
        PlatformConstants.UPDATE_SHOPLIST,
        PlatformConstants.MSGBOX_OK,
	}
end

function ShopListMediator:onRegister()
    print("ShopListMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
    local shopProxy = platformFacade:retrieveProxy("ShopProxy")

    local ui = cc.CSLoader:createNode("hall_res/mall/mall_yuanbao.csb")  --设置UI的csb
	self:setViewComponent(ui)
    self.root:addChild(self:getViewComponent())

    self.bg = seekNodeByName(ui, "yuanbao_bg")--获取背景
 
    local strBg = ""
    local node = nil
    local strType = ""
    local nType = shopProxy:getData().reqType
    print("nType = " .. nType)
    if nType == 2 then --钻石  --以前是self.nType
      --strBg="yuanbao"
      self.strType = "钻石"
    elseif nType == 3 then --房卡
      --strBg="fangka"
      self.strType = "房卡"
    elseif nType == 4 then  --金币
      --strBg="yuanbao"
      self.strType = "金币"    
    end
    strBg="yuanbao"
    --取出一个商品当模板
    self.Template = seekNodeByName(self.bg,  "yuanbao_9")
    if self.Template == nil then
       print("self.Template = nil")
    else
       print("self.Template ~= nil")
       self.Template:setVisible(false)
    end
    --寻找原来的8个节点,将它们隐藏
    for i = 1,8 do
        --print("strBg:" .. strBg)
        local nodeName = strBg .. "_" .. tostring(i)
        --print("nodeName:" .. nodeName)
		local list_itemone = seekNodeByName(ui, nodeName)
		list_itemone:setVisible(false)
	end

    --platformFacade:registerCommand(PlatformConstants.CREATE_MSGBOXEX, cc.exports.StartMsgBoxCommandEx)
    platformFacade:registerCommand(PlatformConstants.REQUEST_DIAMONDBUY, cc.exports.RequestDiamondOrderCommand)
    platformFacade:registerCommand(PlatformConstants.START_PAYSELECT, cc.exports.StartPayChoiceCommand)  --启动支付选择页面

    --设置滚动条
    self.tableView = cc.TableView:create(cc.size(1035,629)) --大小
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.tableView:setPosition(cc.p(0, 0))
    self.tableView:setAnchorPoint(cc.p(0,0))
    self.tableView:setDelegate()
    self.bg:addChild(self.tableView, 255)

    self.tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    self.tableView:registerScriptHandler(handler(self, self.scrollViewDidScroll),cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(handler(self, self.scrollViewDidZoom),cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableView:registerScriptHandler(handler(self, self.tableCellTouched),cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(handler(self, self.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(handler(self, self.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)

    self.tableView:reloadData()
end
--求这个滚动table里有多少个格子
function ShopListMediator:numberOfCellsInTableView(table)
    print("ShopListMediator:numberOfCellsInTableView")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local shopProxy = platformFacade:retrieveProxy("ShopProxy")
    --self.goodsList = shopProxy:getData().curlist
    local goodlist = shopProxy:getData().curlist
    --dump(self.goodsList)
    return  self:nums(goodlist)
end

function ShopListMediator:nums(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    --每8个商品为一个格子
    local counttmp = (count-1)%8
    local countnum = math.ceil(count/8)
    --[[if  counttmp >= 1 then
        return countnum+1
    end--]]
    
    print("ShopListMediator:nums:" .. countnum)
    return countnum
end

function ShopListMediator:scrollViewDidScroll(table)
    --self.tableView:reloadData()
    if table:isTouchMoved() then
        --滑动过程不能响应 屏蔽button事件
        Game_Button_ENABALED = false        
    else
        Game_Button_ENABALED = true        
    end
end

function ShopListMediator:scrollViewDidZoom(table)
    print("scrollViewDidZoom")
end

function ShopListMediator:tableCellTouched(table, cell)
    --print("cell touched at index: " .. cell:getIdx())       
end

function ShopListMediator:cellSizeForTable(table, idx) 
	local width = 1035
	local height = 629
	  
    return  width,height
end

function ShopListMediator:tableCellAtIndex(table, idx)
    print("start ShopListMediator:tableCellAtIndex idx:" .. idx)
    dump(table, "table")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local shopProxy = platformFacade:retrieveProxy("ShopProxy")
    local strValue = string.format("%d", idx)
    local cell = table:dequeueCell()
    if nil == cell then        
        cell = cc.TableViewCell:new()
    end
    cell:removeAllChildren()
    idx = idx + 1

    --print("self.nType = " .. self.nType)
    --dump(self.goodsList, "tableCellAtIndex的self.goodsList表")
    --对每一个商品进行初始化
    self:tableInit(cell, table, idx * Cell_Size - 7)
    self:tableInit(cell, table, idx * Cell_Size - 6)
    self:tableInit(cell, table, idx * Cell_Size - 5)
    self:tableInit(cell, table, idx * Cell_Size - 4)
    self:tableInit(cell, table, idx * Cell_Size - 3)
    self:tableInit(cell, table, idx * Cell_Size - 2)
    self:tableInit(cell, table, idx * Cell_Size - 1)
    self:tableInit(cell, table, idx * Cell_Size)

    print("end ShopListMediator:tableCellAtIndex")
    return cell
end

--显示游戏item
function ShopListMediator:tableInit(cell, table, idx)
    print("start ShopListMediator:tableInit idx:" .. idx)
    --print("tableInit idx:"..idx)
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    local shopProxy = platformFacade:retrieveProxy("ShopProxy")

    if self.Template == nil then
     --print("self.Template = nil return")
     return
    end

    local goodItem = self.Template:clone() --克隆一个模板商品
    if goodItem == nil then
     print("goodItem = nil")
    end
    -- 获取当前商品列表
    local goodsList = shopProxy:getData().curlist
    --local goodsList = self:buildGoldList()

    local size = #goodsList
    print("goodsList size:" .. size)
    if idx>size then
      print("idx>size")
      return
    end
   
    --获取图标名
    local strIcon = goodsList[idx].icon
    print("goodsList idx:" .. idx .. " icon:" .. strIcon)
    if goodItem~=nil then
      --print("goodItem~=nil")
      goodItem:setVisible(true)
      goodItem:setTag(idx)
      --顶部商品数字， 如10房卡
      local toptipNum = goodItem:getChildByName("buy_tip_num")
     
      local nType = goodsList[idx].gainType --当前的商品类型
      local pathPre = "platform_res/mark/"  --图片路径前缀
      local imgSize = cc.size(146, 120)  --图片大小
        if nType == 2 then --钻石
         self.strType = "钻石"
         pathPre = "platform_res/mark/diamond/"
         --imgSize = cc.size(125, 119)
        elseif nType == 3 then --房卡
         --strBg="fangka"
         self.strType = "房卡"
         pathPre = "platform_res/mark/fangka/"
        -- imgSize = cc.size(178, 101)
        elseif nType == 4 then  --金币
        --strBg="yuanbao"
         self.strType = "金币"
         pathPre = "platform_res/mark/gold/"
         --imgSize = cc.size(125, 119)
        end
        local mIco = "platform_res/mark/rmb_icon.png"  --按钮上的货币图标
        local mIcoSize = cc.size(22, 32)
        local payType = goodsList[idx].payType --取得支付类型
        if payType == 2 then --钻石类型
          mIco = "platform_res/mark/zuanshi.png"
          mIcoSize = cc.size(32, 32)
        elseif payType == 1 then
          mIco = "platform_res/mark/rmb_icon.png"
          mIcoSize = cc.size(22, 32)
        end
        --设置购买的标题
        --toptipNum:setString(self.goodsList[idx].gainValue .. self.strType)
        toptipNum:setString(goodsList[idx].title)
        --print("self.goodsList[idx].gainValue .. self.strType:" .. self.goodsList[idx].gainValue .. self.strType)

        local goodIcon = goodItem:getChildByName("yuanbaoimg") --图标
        --设置图标
        if goodIcon then
          if strIcon~="" then
            local iconPath = pathPre .. strIcon
            --print("iconPath:" .. iconPath)
            goodIcon:loadTexture(iconPath)
            --goodIcon:setContentSize(imgSize)
          end
        else
         print("goodIcon = nil")
        end
        --设置购买按钮
        local btn_buy = goodItem:getChildByName("btn_buy_1")
            
	    if btn_buy ~= nil then
		    btn_buy:setVisible(true)
		    btn_buy:setTag(goodsList[idx].id)
            local btnIco = btn_buy:getChildByName("white_rmb")  --按钮上的货币图标
            if btnIco then
             btnIco:loadTexture(mIco)
             btnIco:setContentSize(mIcoSize)
            end
		    --购买按钮监听
		    btn_buy:addClickEventListener(function(btn,event)
                 print("单击购买按钮, 购买类型：" .. goodsList[idx].payType)
                        -- Music:playEffect(EFFECT_BUTTON)
                        --[[if g_payByWebView and tostring(g_payByWebView) == "true" then
                            self:yuanbaoListItemListenerByWebView(btn)
                        else 
                            self:yuanbaoListItemListener(btn, "com.bzw.zuanshi")
                        end
                        --]]
                  self.curBtnTag = btn:getTag()
                  if goodsList[idx].payType == 1 then  --人民币购买
                    print("人民币购买")                
                    platformFacade:sendNotification(PlatformConstants.START_PAYSELECT, btn_buy:getTag())
                   -- platformFacade:sendNotification("wx_order", btn:getTag())
                    --platformFacade:sendNotification("ali_order", btn:getTag())
                  elseif goodsList[idx].payType == 2 then --钻石购买
                    print("钻石购买")
                    local PlatformConstants = cc.exports.PlatformConstants
                    local strMsg = "您确认以" .. goodsList[idx].payValue .. "钻石购买" .. goodsList[idx].title .. "吗?"
                    local function okCall()  --确定按钮回调
                         self:diamondBuy()  --钻石购买
                    end 
                    local tMsg = {mType = 2, code = 1, msg = strMsg, okCallback = okCall} --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
                    platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX_EX, tMsg)  --弹出MsgBox，等用户确定。真正的购买请求在MSGBOX_OK消息处理里
                 else
                    platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "功能待开放")
                  end
		    end)
				
            local price_num = btn_buy:getChildByName("price_white_num")
            price_num:enableOutline(cc.c3b(173, 35, 0), 2)
            price_num:setTextHorizontalAlignment(1)   --设置左对齐  1:居中 2:右对齐
            local payMoney = goodsList[idx].payValue
            if payType == 1 then --人民币类型
               payMoney = payMoney/100  --单位为分
            end
		    price_num:setString(payMoney)  --设置支付金额
        else
         print("btn_buy = nil")
	    end

	    --设置单元格内8个商品的位置
	    if idx % Cell_Size == 1 then 
		 --print("idx % cell_Size = 1")       
		  goodItem:setPosition(cc.p(140, 453))        
	    elseif idx % Cell_Size == 2 then        
		  --print("idx % cell_Size = 2")  
		  goodItem:setPosition(cc.p(396, 453))              
	    elseif idx % Cell_Size == 3 then        
	     -- print("idx % cell_Size = 3")  
		  goodItem:setPosition(cc.p(652, 453))
	    elseif idx % Cell_Size == 4 then 
		  -- print("idx % cell_Size = 4")         
		  goodItem:setPosition(cc.p(908, 453))
	    elseif idx % Cell_Size == 5 then
		 -- print("idx % cell_Size = 5")          
		  goodItem:setPosition(cc.p(140, 154))
	    elseif idx % Cell_Size == 6 then 
		 -- print("idx % cell_Size = 6")         
		  goodItem:setPosition(cc.p(396, 154))
	    elseif idx % Cell_Size == 7 then
		  -- print("idx % cell_Size = 7")          
		  goodItem:setPosition(cc.p(652, 154))
	    else 
		  -- print("idx % cell_Size = 0")  
		  goodItem:setPosition(cc.p(908, 154))
	    end

	   cell:addChild(goodItem)
    end  --endif goodItem~=nil then

end

function ShopListMediator:handleNotification(notification)
    print("ShopListMediator `111111111  :handleNotification")
    local name = notification:getName()
    local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local shopProxy = platformFacade:retrieveProxy("ShopProxy")
    local msgProxy = platformFacade:retrieveProxy("MsgBoxProxy")
   -- local goodList = notification:getBody()

    if name == PlatformConstants.UPDATE_SHOPLIST then
      print("handle UPDATE_SHOPLIST")
      
      local nType = shopProxy:getData().reqType  --得到那请求商品类型
      print("nType = " .. nType)
      if nType == 2 then  --钻石 self.nType
        --self.goodsList = shopProxy:getData().diamondlist
        shopProxy:getData().curlist = shopProxy:getData().diamondlist
        --dump(shopProxy:getData().diamondlist,"shopProxy:getData().diamondlist")
      elseif nType == 3 then --房卡
        --self.goodsList = shopProxy:getData().fangkalist
        shopProxy:getData().curlist = shopProxy:getData().fangkalist
        --dump(shopProxy:getData().fangkalist,"shopProxy:getData().fangkalist")
      elseif nType == 4 then --金币
        shopProxy:getData().curlist = shopProxy:getData().coinlist 
      end
      
      --dump(self.goodsList, "update后的self.goodsList")
      --dump(self.tableView, "tableView")
      print("self.tableView:reloadData()")
      self.tableView:reloadData()
      --延后0.3秒再调用一次，防止滚动时numberOfCellsInTableView获得的格子数还是老数据造成崩crash
      performWithDelay( self:getViewComponent() , function()
            print("second tableView:reloadData")
            self.tableView:reloadData()
        end , 0.3)
      
      --local pt = self.tableView:minContainerOffset()
      --self.tableView:setContentOffset(pt)
    elseif name == PlatformConstants.MSGBOX_OK then --确定框点OK
       --local code = msgProxy:getData().code
       print("you click MSGBOX_OK")
    end
    
end

--钻石购买
function ShopListMediator:diamondBuy()
   --钻石购买
   local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
   local PlatformConstants = cc.exports.PlatformConstants
   platformFacade:sendNotification(PlatformConstants.REQUEST_DIAMONDBUY, self.curBtnTag)
end

function ShopListMediator:onRemove()
    print("ShopListMediator:onRemove")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
    --platformFacade:removeCommand(PlatformConstants.CREATE_MSGBOXEX)
    platformFacade:removeCommand(PlatformConstants.REQUEST_DIAMONDBUY)

    self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)

end

--构造初始化数据
function ShopListMediator:buildGoldList()
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

return ShopListMediator
--endregion
