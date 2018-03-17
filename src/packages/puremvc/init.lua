
local _M = {}
_M.VERSION = "1.0.0"
_M.FRAMEWORK_NAME = "puremvc lua"
_M.PACKAGE_NAME = "org.puremvc.lua.multicore"

_M.Controller = import("." .. _M.PACKAGE_NAME .. ".core.Controller")
_M.Model = import("." .. _M.PACKAGE_NAME .. ".core.Model")
_M.View = import("." .. _M.PACKAGE_NAME .. ".core.View")

_M.Facade = import("." .. _M.PACKAGE_NAME .. ".patterns.facade.Facade")
_M.Mediator = import("." .. _M.PACKAGE_NAME .. ".patterns.mediator.Mediator")
_M.Proxy = import("." .. _M.PACKAGE_NAME .. ".patterns.proxy.Proxy")
_M.SimpleCommand = import("." .. _M.PACKAGE_NAME .. ".patterns.command.SimpleCommand")
_M.MacroCommand = import("." .. _M.PACKAGE_NAME .. ".patterns.command.MacroCommand")
_M.Notifier = import("." .. _M.PACKAGE_NAME .. ".patterns.observer.Notifier")
_M.Notification = import("." .. _M.PACKAGE_NAME .. ".patterns.observer.Notification")
_M.Observer = import("." .. _M.PACKAGE_NAME .. ".patterns.observer.Observer")

print("")
print("# FRAMEWORK_NAME           = " .. _M.FRAMEWORK_NAME)
print("# VERSION                  = " .. _M.VERSION)
print("")

return _M