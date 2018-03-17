
cc.FileUtils:getInstance():addSearchPath("game")

import(".GameConstants")

import(".components.chat.init")
import(".components.desk.init")
import(".components.location.init")
import(".components.network.init")
import(".components.scene.init")
import(".components.voice.init")
import(".components.message.init")


local gameFacade = cc.load("puremvc").Facade.getInstance("game")
local GameConstants = cc.exports.GameConstants

gameFacade:registerCommand(GameConstants.START_TCP, cc.exports.StartTcpCommand)
gameFacade:registerCommand(GameConstants.START_REDDOT, cc.exports.StartReddotCommand)

gameFacade:registerCommand(GameConstants.REQUEST_PRVCONNECT, cc.exports.RequestPrivateConnectCommand)
gameFacade:registerCommand(GameConstants.REQUEST_PRVROOM, cc.exports.RequestPrivateRoomCommand)
gameFacade:registerCommand(GameConstants.REQUEST_PRVSIT, cc.exports.RequestPrivateSitCommand)

gameFacade:registerCommand(GameConstants.REQUEST_QUKCONNECT, cc.exports.RequestQuickConnectCommand)
gameFacade:registerCommand(GameConstants.REQUEST_QUKQUEUE, cc.exports.RequestQuickQueueCommand)
gameFacade:registerCommand(GameConstants.REQUEST_QUKCACQUE, cc.exports.RequestQuickCancelQueueCommand)
gameFacade:registerCommand(GameConstants.REQUEST_QUKLEAVE, cc.exports.RequestQuickLeaveCommand)

gameFacade:registerCommand(GameConstants.REQUEST_FRECONNECT, cc.exports.RequestFreeConnectCommand)
gameFacade:registerCommand(GameConstants.REQUEST_FRESIT, cc.exports.RequestFreeSitCommand)
gameFacade:registerCommand(GameConstants.REQUEST_FRELEAVE, cc.exports.RequestFreeLeaveCommand)

gameFacade:registerCommand(GameConstants.START_MESSAGE, cc.exports.StartGameMessageCommand)
gameFacade:registerCommand(GameConstants.CREATE_MSGBOX, cc.exports.StartCreateGameMsgBoxCommand)

gameFacade:registerCommand(GameConstants.REQUEST_VIDEOCREATE, cc.exports.RequestCreateVideoCommand)

gameFacade:registerCommand(GameConstants.START_GAME, cc.exports.StartGameCommand)
