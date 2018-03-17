
local Mediator = cc.load("puremvc").Mediator
local RoomConfigMediator = class("RoomConfigMediator", Mediator)

function RoomConfigMediator:ctor(root)
	RoomConfigMediator.super.ctor(self, "RoomConfigMediator", root)
end

function RoomConfigMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.UPDATE_ROOMCFG, 
		PlatformConstants.UPDATE_ROOMCHC, 
	}
end

function RoomConfigMediator:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	platformFacade:registerCommand(PlatformConstants.ADD_ROOMCHC, cc.exports.AddChoiceCommand)
	platformFacade:registerCommand(PlatformConstants.SUB_ROOMCHC, cc.exports.SubChoiceCommand)
	platformFacade:registerCommand(PlatformConstants.CHG_ROOMCHC, cc.exports.ChangeChoiceCommand)

	local ui = self:getViewComponent()	
    self.list = seekNodeByName(ui, "ListView_gameconfig")
    self.list:setScrollBarEnabled(false)
    self.list:removeAllChildren()
    self.columnTemp = seekNodeByName(ui, "Panel_item")
    self.boxTemp = seekNodeByName(ui, "Btn_box")
    self.radioTemp = seekNodeByName(ui, "Btn_radio")
end

function RoomConfigMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	platformFacade:removeCommand(PlatformConstants.ADD_ROOMCHC)
	platformFacade:removeCommand(PlatformConstants.SUB_ROOMCHC)
	platformFacade:removeCommand(PlatformConstants.CHG_ROOMCHC)
end

function RoomConfigMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	print("createRoom",name)
	dump(body,"createRoomBody")
	local PlatformConstants = cc.exports.PlatformConstants
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	if name == PlatformConstants.UPDATE_ROOMCFG then
		self.list:removeAllChildren()
		local allHeight = 0
		local allItm = {}
		for _,v in ipairs(body) do
			local item = self.columnTemp:clone()
			item:setTag(v.id)
			item:setVisible(true)
			local txtName = seekNodeByName(item, "Text_name")
			txtName:setVisible(true)
			txtName:setString(v.optionName .. ":")
			local panelElement = seekNodeByName(item, "Panel_element")
			local maxWidth, rowHeight = panelElement:getContentSize().width, panelElement:getContentSize().height
			local startX = txtName:getPositionX() + txtName:getContentSize().width + 30
			local row = 1
			local rowElm = {{}}
			for i,c in ipairs(v.optionList) do
				local elm
				local elementLen = 0
				if v.optionType == 1 then
					elm = self.radioTemp:clone()
					elm:setVisible(true)
					elm:addClickEventListener(function()
						platformFacade:sendNotification(PlatformConstants.CHG_ROOMCHC, c.optionId, v.id)
					end)
					local name = seekNodeByName(elm, "Text")
					name:setString(c.description)
					local touch = seekNodeByName(elm, "Panel_touch")
					touch:setContentSize(cc.size(name:getContentSize().width, touch:getContentSize().height))
					touch:addClickEventListener(function()
						platformFacade:sendNotification(PlatformConstants.CHG_ROOMCHC, c.optionId, v.id)
					end)
					elementLen = name:getContentSize().width + 30
				elseif v.optionType == 2 then
					elm = self.boxTemp:clone()
					elm:setVisible(true)
					local name = seekNodeByName(elm, "Text")
					name:setString(c.description)
					elm:addEventListener(function(sender, evt)
						if evt == ccui.CheckBoxEventType.selected then
							platformFacade:sendNotification(PlatformConstants.ADD_ROOMCHC, c.optionId, v.id)
						elseif evt == ccui.CheckBoxEventType.unselected then
							platformFacade:sendNotification(PlatformConstants.SUB_ROOMCHC, c.optionId, v.id)
						end
					end)
					local touch = seekNodeByName(elm, "Panel_touch")
					touch:setContentSize(cc.size(name:getContentSize().width, touch:getContentSize().height))
					touch:addClickEventListener(function(sender)
						local selected = sender:getParent():isSelected()
						platformFacade:sendNotification(selected and PlatformConstants.SUB_ROOMCHC or PlatformConstants.ADD_ROOMCHC, c.optionId, v.id)
					end)
					elementLen = name:getContentSize().width + 30
				end
				if elementLen + startX > maxWidth then
					row = row + 1
					rowElm[row] = {}
					startX = 30
					elm:setPositionX(startX)
					startX = startX + elementLen + 30
					table.insert(rowElm[row], elm)
				else
					elm:setPositionX(startX)
					startX = startX + elementLen + 30
					table.insert(rowElm[row], elm)
				end
				elm:setTag(c.optionId)
				panelElement:addChild(elm)
			end
			panelElement:setContentSize(cc.size(maxWidth, rowHeight*row))
			panelElement:setPositionY(rowHeight*row+1)
			local bg = seekNodeByName(item, "Image_bg")
			bg:setContentSize(cc.size(bg:getContentSize().width, rowHeight*row))
			bg:setPositionY(rowHeight*row+1)
			txtName:setPositionY(rowHeight*row+2-rowHeight/2)
			for i,r in ipairs(rowElm) do
				for _,e in ipairs(r) do
					e:setPositionY(rowHeight*(row-i+1)-rowHeight/2)
				end
			end
			item:setContentSize(cc.size(item:getContentSize().width, rowHeight*row+2))
			allHeight = allHeight + item:getContentSize().height
			item:setPositionX(0)
			table.insert(allItm, item)
			self.list:addChild(item)
		end
		local outterWidth, outterHeight = self.list:getContentSize().width, self.list:getContentSize().height
		local innerWidth, innerHeight = self.list:getInnerContainerSize().width, self.list:getInnerContainerSize().height
		self.list:setInnerContainerSize(cc.size(self.list:getInnerContainerSize().width, allHeight>outterHeight and allHeight or outterHeight))
		local minusTop = 0
		for _,v in ipairs(allItm) do
			v:setPositionY(self.list:getInnerContainerSize().height-minusTop)
			minusTop = minusTop + v:getContentSize().height
		end
		self.list:jumpToTop()
	elseif name == PlatformConstants.UPDATE_ROOMCHC then
		--选择小圆点的效果实现，如同radiobutton 或checkbox
		for _,v in ipairs(body) do
			local column = self.list:getChildByTag(v.id)  --获取一列
			local panelElement = seekNodeByName(column, "Panel_element")
			--找到每一项
			if v.tp == 1 then	
				for _,e in ipairs(panelElement:getChildren()) do
					if e:getTag() == v.choice then
						e:setEnabled(false)					
						e:setColor(ccc3(255,247,153))
					else
						e:setEnabled(true)
						e:setColor(ccc3(196,221,254))
					end
				end
			elseif v.tp == 2 then
				
				for _,e in ipairs(panelElement:getChildren()) do
					if table.indexof(v.choice, e:getTag()) then
						e:setSelected(true)
						e:setColor(ccc3(255,247,153))
					else
						e:setSelected(false)
						e:setColor(ccc3(196,221,254))
					end
				end
			end
		end
	end
end

return RoomConfigMediator