local GameLogic = import("....GameLogic")
local CheckTingMediator = import("..mediator.CheckTingMediator")
local CheckTingProxy = import("..proxy.CheckTingProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local CheckTingCommand = class("CheckTingCommand", SimpleCommand)

function CheckTingCommand:execute(notification)
    print("CheckTingCommand:execute")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()

    local handCard = gameFacade:retrieveProxy("HandCardProxy"):getData()
    local desk = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
    local huCards = GameLogic:getHuCards(handCard.SelfHandCards,body.value,desk.LaiZi,desk.IsCan7Dui)

    if #huCards > 0 then
        if not gameFacade:hasMediator("CheckTingMediator") then
            gameFacade:registerProxy(CheckTingProxy.new())
            gameFacade:registerMediator(CheckTingMediator.new(root))
        end
        local data = gameFacade:retrieveProxy("CheckTingProxy"):getData()
        data.CardData = huCards
    else
        if gameFacade:hasMediator("CheckTingMediator") then
            gameFacade:sendNotification(MyGameConstants.C_CLOSE_TINGCARDS)
        end
    end
end

return CheckTingCommand