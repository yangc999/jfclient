
print("init 22000401")

cc.FileUtils:getInstance():addSearchPath("game/22000401")
import(".MyGameConstants")

import(".components.base.init")
import(".components.deskinfo.init")
import(".components.handcard.init")
import(".components.checkting.init")
import(".components.outcard.init")
import(".components.playerinfo.init")
import(".components.cpgmenu.init")
import(".components.menu.init")
import(".components.result.init")
import(".components.resulttotal.init")
import(".components.rules.init")
import(".components.help.init")
import(".components.loading.init")
import(".components.setting.init")
import(".components.test.init")
import(".components.video.init")

local gameFacade = cc.load("puremvc").Facade.getInstance("game")
local GameConstants = cc.exports.GameConstants

gameFacade:registerCommand(GameConstants.SHOW_GAME, cc.exports.ShowMainCommand)
