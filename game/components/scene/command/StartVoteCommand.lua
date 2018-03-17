
local VoteProxy = import("..proxy.VoteProxy")
local VoteMediator = import("..mediator.VoteMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartVoteCommand = class("StartVoteCommand", SimpleCommand)

function StartVoteCommand:execute(notification)
	local scene = notification:getBody()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	gameFacade:registerProxy(VoteProxy.new())
	gameFacade:registerMediator(VoteMediator.new())
end

return StartVoteCommand