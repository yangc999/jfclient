-- local SimpleCommand = cc.load("puremvc").SimpleCommand
-- local UpdatePrivateRoomCommand = class("UpdatePrivateRoomCommand", SimpleCommand)

-- function UpdatePrivateRoomCommand:execute(notification)
--     print("-------------->UpdatePrivateRoomCommand:execute")
-- 	local name = notification:getName()
--     local body = notification:getBody()
--     local tp = notification:getType()
--     local MyGameConstants = cc.exports.MyGameConstants
--     local gameFacade = cc.load("puremvc").Facade.getInstance("game")

--     if name == MyGameConstants.C_PIAO_REQ then
--         -- º”∆Æ«Î«Û
--         local pak1 = {
--             iCID = GameUtils:getInstance():getSelfServerChair(),
--             iPiaoPoint = body.value
--         }
--         GameUtils:getInstance():sendNotification(19, pak1, "MJProto::TMJ_actionJiaPiao")
--     end
-- end

-- return PiaoReqCommand