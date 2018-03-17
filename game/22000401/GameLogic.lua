--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local GameLogic = class("GameLogic")

-- 得到出牌可以听的牌 handCards 手牌 laiZiValue 癞子值表 isCan7Dui 能否胡7对
function GameLogic:getTingCards(handCards,laiZiTab,isCan7Dui)
    print("GameLogic:getTingCards")
    --dump(handCards,"handCards")
    local outCardTing = {}
    local singleCards = self:getSingle(handCards)
    for k,v in pairs(singleCards) do
        local temp = clone(handCards)
        self:removeOneItemInTable(temp,v)
        local temp1,laiZiNums = self:getNoLZTab(temp,laiZiTab)   -- 无癞子table, 癞子数
        if self:check_3x_2(temp1,laiZiNums + 1) == true or self:check_7Dui(temp1,laiZiNums + 1,isCan7Dui) == true then
            table.insert(outCardTing,v)
        end
    end

    return outCardTing
end

-- 得到出当前牌可以胡的牌
function GameLogic:getHuCards(handCards,outCard,laiZiTab,isCan7Dui)
    print("GameLogic:getHuCards")
    --dump(handCards,"handCards")
    local huCards = {}
    local temp = clone(handCards)
    self:removeOneItemInTable(temp,outCard)
    self:sort(temp)
    local temp1,laiZiNums = self:getNoLZTab(temp,laiZiTab)   -- 无癞子table, 癞子数
    for i=1,30 do
        if i %10 ~= 0 then
            local temp2 = clone(temp1)
            table.insert(temp2,i)
            self:sort(temp2)
            if self:check_3x_2(temp2,laiZiNums) == true or self:check_7Dui(temp2,laiZiNums,isCan7Dui) == true then
                table.insert(huCards,i)
            end
        end
    end

    return huCards
end

-- 检测是否是3x_2牌型  tab 无癞子手牌   laiZiNums 癞子个数
function GameLogic:check_3x_2(tab,laiZiNums)
    --print("GameLogic:check_3x_2")
    --print("laiZiNums = " .. tostring(laiZiNums))
    --dump(tab,"tab")
    if (#tab + laiZiNums) % 3 ~= 2 then
        return false
    end

    -- 全是癞子胡牌
    if #tab == 0 then
        return true
    end
    
    self:sort(tab)
    local value = 0
    for k,v in pairs(tab) do
        if value ~= v then
            value = v
            local temp = clone(tab)
            local nums = self:getValueNums(v,temp)
            if nums >= 2 then            -- 一对作将
                self:removeOneItemInTable(temp,v)
                self:removeOneItemInTable(temp,v)
                if self:check_3x(temp,laiZiNums) == true then
                    return true
                end
            elseif laiZiNums >= 1 then   -- 单张加一个癞子作将
                self:removeOneItemInTable(temp,v)
                if self:check_3x(temp,laiZiNums - 1) == true then
                    return true
                end
            end
        end
    end

    -- 两个癞子作将
    if laiZiNums >= 2 then
        if self:check_3x(tab,laiZiNums - 2) == true then
            return true
        end
    end

    return false
end

-- 检测是否是3x牌型
function GameLogic:check_3x(tab,laiZiNums)
    if #tab == 0 then
        return true
    end

    -- 检测刻子
    local temp1 = clone(tab)
    local bHave1,num1 = self:check_triplet(temp1,laiZiNums)
    if bHave1 == true then
        if self:check_3x(temp1,num1) then
            return true
        end
    end

    -- 检测顺子
    local temp2 = clone(tab)
    local bHave2,num2 = self:check_straight(temp2,laiZiNums)
    if bHave2 == true then
        if self:check_3x(temp2,num2) then
            return true
        end
    end

    return false
end

-- 检测是否有刻子
function GameLogic:check_triplet(tab,laiZiNums)
    local bHave = false
    local num = laiZiNums

    local value = tab[1]
    local valueNums = self:getValueNums(tab[1],tab)
    if valueNums == 1 then
        if num >= 2 then
            self:removeOneItemInTable(tab, value)
            num = num - 2
            bHave = true
        end
    elseif valueNums == 2 then
        if num >= 1 then
            self:removeOneItemInTable(tab, value)
            self:removeOneItemInTable(tab, value)
            num = num - 1
            bHave = true
        end
    elseif valueNums >= 3 then
        self:removeOneItemInTable(tab, value)
        self:removeOneItemInTable(tab, value)
        self:removeOneItemInTable(tab, value)
        bHave = true
    end

    return bHave,num
end

-- 检测是否有顺子
function GameLogic:check_straight(tab,laiZiNums)
    local bHave = false
    local num = laiZiNums
    if tab[1] < 30 and tab[1] % 10 <= 8 then
        local value = tab[1]
        local bExist1 = self:isInTable(value + 1,tab)
        local bExist2 = self:isInTable(value + 2,tab)
        if bExist1 and bExist2 then
            self:removeOneItemInTable(tab,value)
            self:removeOneItemInTable(tab,value + 1)
            self:removeOneItemInTable(tab,value + 2)
            bHave = true
        elseif bExist1 and not bExist2 then
            if num >= 1 then
                self:removeOneItemInTable(tab, value)
                self:removeOneItemInTable(tab, value + 1)
                num = num - 1
                bHave = true
            end
        elseif bExist2 and not bExist1 then
            if num >= 1 then
                self:removeOneItemInTable(tab, value)
                self:removeOneItemInTable(tab, value + 2)
                num = num - 1
                bHave = true
            end
        elseif not bExist1 and not bExist2 then
            if num >= 2 then
                self:removeOneItemInTable(tab, value)
                num = num - 2
                bHave = true
            end
        end
    end
    
    return bHave,num
end

-- 检测7对
function GameLogic:check_7Dui(tab,laiZiNums,isCan7Dui)
    print("GameLogic:check_7Dui")
    if isCan7Dui == false then
        return false
    end
    if #tab + laiZiNums ~= 14 then
        return false
    end
    
    local needLZNums = 0  -- 组成7对所需癞子个数
    local value = 0
    for k,v in pairs(tab) do
        if value ~= v then
            value = v
            if self:getValueNums(v,tab) % 2 ~= 0 then
                needLZNums = needLZNums + 1
            end
        end
    end

    if needLZNums <= laiZiNums then
        return true
    end

    return false
end


---------------------------------------------------------------------------------------
--删除某个表中对应的某一个值
function GameLogic:removeOneItemInTable( tbl , item)
    for i,v in pairs (tbl) do
        if item == v then
            table.remove(tbl,i)
            break
        end
    end
end

--表中是否包含某个值
function GameLogic:isInTable(value, tbl)
    if tbl then
        for k,v in ipairs(tbl) do
          if v == value then
            return true
          end
        end
    end
    return false
end

-- 获取一张牌在tab中的数量
function GameLogic:getValueNums(vaule,tab)
    local num = 0
    for i,v in pairs (tab) do
        if tonumber(v) == tonumber(vaule) then
            num = num + 1
        end
    end

    return num
end

-- 获取无癞子tab
function GameLogic:getNoLZTab(tab, laiZiTab)
    local temp = clone(tab)
    local nums= #temp
    local laiZiNums = 0
    if #laiZiTab > 0 then
        for i = 1, nums do
            for k, v in pairs(temp) do
                if self:isInTable(v, laiZiTab) then
                    self:removeOneItemInTable(temp, v)
                    laiZiNums = laiZiNums + 1
                    break
                end
            end
        end
    end

    return temp, laiZiNums
end

-- 获取一个表去重后的表(不改变原有表)
function GameLogic:getSingle(tbl)
    local kv = {}
    for i,v in pairs (tbl) do
        kv[v] = v 
    end
    local result = {}
    for i,v in pairs (kv) do
        table.insert(result,v)
    end
    table.sort(result,function(a,b)
        return a<b
    end)

    return result
end

-- 排序(癞子放到前面)
function GameLogic:sort(cards, laizs)
    if cards == nil or #cards == 0 then
        return
    end

    table.sort(cards, function(a, b)
        if laizs == nil or #laizs <= 0 then
            return a < b
        else
            -- 有赖子情况
            local aIsLaizi = self:isInTable(a, laizs)
            local bIsLaizi = self:isInTable(b, laizs)

            if aIsLaizi and bIsLaizi then
                return a < b
            elseif aIsLaizi then
                return true
            elseif bIsLaizi then
                return false
            else
                return a < b
            end
        end
    end )
end


return GameLogic


---------------------------------------------------------------------------------------

--endregion
