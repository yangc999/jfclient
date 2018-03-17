
local SimpleCommand = cc.load("puremvc").SimpleCommand
local AdvanceCommand = class("AdvanceCommand", SimpleCommand)

function AdvanceCommand:execute(notification)
    print("-------------->AdvanceCommand:execute")
    local name = notification:getName()
    local body = notification:getBody()
    local tp = notification:getType()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("VideoProxy"):getData()

    if name == MyGameConstants.C_ADVANCE then
        local root = gameFacade:retrieveMediator("VideoMediator").root
        root:stopAllActions()
        if data.CurIndex < data.AllIndex - 1 then
            data.CurIndex = data.CurIndex + 1
            performWithDelay(root, function()
                gameFacade:sendNotification(MyGameConstants.C_GAME_INIT)
                gameFacade:sendNotification(MyGameConstants.C_PLAY_VIDEO,{})
            end , 1)
        elseif data.CurIndex == data.AllIndex - 1 then  -- 快进到最后一帧直接显示结算界面
            gameFacade:sendNotification(MyGameConstants.C_PLAY_VIDEO)
        end
    end
end

return AdvanceCommand