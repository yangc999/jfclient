
local SimpleCommand = cc.load("puremvc").SimpleCommand
local BackwardCommand = class("BackwardCommand", SimpleCommand)

function BackwardCommand:execute(notification)
    print("-------------->BackwardCommand:execute")
    local name = notification:getName()
    local body = notification:getBody()
    local tp = notification:getType()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("VideoProxy"):getData()

    if name == MyGameConstants.C_BACKWARD then
        local root = gameFacade:retrieveMediator("VideoMediator").root
        root:stopAllActions()
        if data.CurIndex == data.AllIndex then
            gameFacade:sendNotification(MyGameConstants.C_CLOSE_RESULT)
        end
        if data.CurIndex > 1 then
            data.CurIndex = data.CurIndex - 1
            performWithDelay(root, function()
                gameFacade:sendNotification(MyGameConstants.C_GAME_INIT)
                gameFacade:sendNotification(MyGameConstants.C_PLAY_VIDEO,{})
            end , 1)
        end
    end
end

return BackwardCommand