
local SimpleCommand = cc.load("puremvc").SimpleCommand
local UpdateShowDeskCommand = class("UpdateShowDeskCommand", SimpleCommand)

function UpdateShowDeskCommand:execute(notification)
	local gameId = notification:getBody()
	print("gameId", gameId)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local gamelist = platformFacade:retrieveProxy("GameListProxy")
	local roomlist = platformFacade:retrieveProxy("RoomListProxy")
	local gamelist = platformFacade:retrieveProxy("GameListProxy")
	roomlist:getData().gameId = gameId
	if gamelist:getData().public[gameId] then
		roomlist:getData().public = gamelist:getData().public[gameId]
	end
	dump(roomlist:getData().public, "public")
	if gamelist:getData().quick[gameId] then
		roomlist:getData().quick = gamelist:getData().quick[gameId]
	end
	dump(roomlist:getData().quick, "quick")
	platformFacade:sendNotification(PlatformConstants.SHOW_ROOMLIST)
end

return UpdateShowDeskCommand